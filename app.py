
from flask import Flask, render_template, redirect, url_for, request, session, flash
from db import get_db_connection
from utils import hash_password, verify_password
from config import Config
import psycopg2


"""
Основной модуль Flask-приложения CorpPanel.
Реализует аутентификацию, разграничение ролей и работу с таблицами БД через веб-интерфейс.
"""

app = Flask(__name__)
app.config.from_object(Config)

# --- Роли и пользователи (логин через БД PostgreSQL) ---
USER_ROLE_MAP = {
    'anna_hr': 'hr_manager',
    'oleg_sec': 'security_officer',
    'ivan_emp': 'department_employee',
}

def get_user_role(username):
    """
    Получить роль пользователя по имени.
    :param username: Имя пользователя
    :return: Роль (строка) или None
    """
    return USER_ROLE_MAP.get(username)

def is_logged_in():
    """
    Проверяет, авторизован ли пользователь.
    :return: True, если пользователь в сессии
    """
    return 'username' in session

def require_role(*roles):
    """
    Декоратор для ограничения доступа по ролям.
    :param roles: Разрешённые роли
    """
    def decorator(f):
        def wrapper(*args, **kwargs):
            if not is_logged_in() or session.get('role') not in roles:
                flash('Доступ запрещён!')
                return redirect(url_for('login'))
            return f(*args, **kwargs)
        wrapper.__name__ = f.__name__
        return wrapper
    return decorator

@app.route('/')
def index():
    """
    Корневой маршрут. Перенаправляет на login или dashboard.
    """
    if not is_logged_in():
        return redirect(url_for('login'))
    return redirect(url_for('dashboard'))

@app.route('/login', methods=['GET', 'POST'])
def login():
    """
    Страница входа. Обрабатывает POST для аутентификации.
    """
    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']
        role = get_user_role(username)
        if not role:
            flash('Пользователь не найден!')
            return render_template('login.html')
        # Проверка пароля через подключение к БД
        try:
            conn = get_db_connection()
            cur = conn.cursor()
            cur.execute("SELECT 1 FROM pg_user WHERE usename=%s AND passwd IS NOT NULL", (username,))
            # В реальном проекте используйте pgcrypto или отдельную таблицу пользователей
            # Здесь просто проверяем, что пользователь есть
            cur.close()
            conn.close()
            # Для теста: пароль = 'secure_password_...' (см. SQL)
            if (username == 'anna_hr' and password == 'secure_password_anna') or \
               (username == 'oleg_sec' and password == 'secure_password_oleg') or \
               (username == 'ivan_emp' and password == 'secure_password_ivan'):
                session['username'] = username
                session['role'] = role
                return redirect(url_for('dashboard'))
            else:
                flash('Неверный пароль!')
        except Exception as e:
            flash(f'Ошибка подключения к БД: {e}')
    return render_template('login.html')

@app.route('/logout')
def logout():
    """
    Выход пользователя. Очищает сессию.
    """
    session.clear()
    return redirect(url_for('login'))

@app.route('/dashboard')
def dashboard():
    """
    Главная страница после входа. Показывает меню по ролям.
    """
    if not is_logged_in():
        return redirect(url_for('login'))
    return render_template('dashboard.html', role=session.get('role'))

# --- Управление персоналом (hr_manager) ---
@app.route('/personnel', methods=['GET', 'POST'])
@require_role('hr_manager')
def personnel():
    """
    Управление персоналом (CRUD). Только для HR-менеджера.
    """
    conn = get_db_connection()
    cur = conn.cursor()
    if request.method == 'POST':
        # Добавление сотрудника
        full_name = request.form['full_name']
        division_id = request.form['division_id']
        role_ = request.form['role']
        join_date = request.form['join_date']
        personal_email = request.form['personal_email']
        contact_number = request.form['contact_number']
        work_phone = request.form['work_phone']
        try:
            cur.execute('''INSERT INTO personnel (full_name, division_id, role, join_date, personal_email, contact_number, work_phone)
                VALUES (%s, %s, %s, %s, %s, %s, %s)''',
                (full_name, int(division_id) if division_id else None, role_, join_date, personal_email, contact_number or None, work_phone or None))
            conn.commit()
            flash('Сотрудник добавлен!')
        except Exception as e:
            conn.rollback()
            flash(f'Ошибка: {e}')
    cur.execute('SELECT * FROM personnel ORDER BY personnel_id')
    personnel_list = cur.fetchall()
    cur.execute('SELECT division_id, division_name FROM divisions ORDER BY division_id')
    divisions = cur.fetchall()
    cur.close()
    conn.close()
    return render_template('personnel.html', personnel=personnel_list, divisions=divisions)

@app.route('/personnel/delete/<int:personnel_id>')
@require_role('hr_manager')
def delete_personnel(personnel_id):
    """
    Удаление сотрудника по ID. Только для HR-менеджера.
    """
    conn = get_db_connection()
    cur = conn.cursor()
    try:
        cur.execute('DELETE FROM personnel WHERE personnel_id=%s', (personnel_id,))
        conn.commit()
        flash('Сотрудник удалён!')
    except Exception as e:
        conn.rollback()
        flash(f'Ошибка: {e}')
    cur.close()
    conn.close()
    return redirect(url_for('personnel'))

# --- Управление отделами (hr_manager) ---
@app.route('/divisions', methods=['GET', 'POST'])
@require_role('hr_manager')
def divisions():
    """
    Управление отделами (CRUD). Только для HR-менеджера.
    """
    conn = get_db_connection()
    cur = conn.cursor()
    if request.method == 'POST':
        division_name = request.form['division_name']
        director_id = request.form['director_id'] or None
        try:
            cur.execute('INSERT INTO divisions (division_name, director_id) VALUES (%s, %s)', (division_name, director_id))
            conn.commit()
            flash('Отдел добавлен!')
        except Exception as e:
            conn.rollback()
            flash(f'Ошибка: {e}')
    cur.execute('SELECT * FROM divisions ORDER BY division_id')
    divisions_list = cur.fetchall()
    cur.execute('SELECT personnel_id, full_name FROM personnel ORDER BY full_name')
    personnel = cur.fetchall()
    cur.close()
    conn.close()
    return render_template('divisions.html', divisions=divisions_list, personnel=personnel)

@app.route('/divisions/delete/<int:division_id>')
@require_role('hr_manager')
def delete_division(division_id):
    """
    Удаление отдела по ID. Только для HR-менеджера.
    """
    conn = get_db_connection()
    cur = conn.cursor()
    try:
        cur.execute('DELETE FROM divisions WHERE division_id=%s', (division_id,))
        conn.commit()
        flash('Отдел удалён!')
    except Exception as e:
        conn.rollback()
        flash(f'Ошибка: {e}')
    cur.close()
    conn.close()
    return redirect(url_for('divisions'))

# --- Просмотр пропусков (security_officer) ---
@app.route('/badges')
@require_role('security_officer')
def badges():
    """
    Просмотр пропусков. Только для сотрудника ИБ.
    """
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute('''SELECT b.badge_id, p.full_name, b.issuance_date, b.is_valid
                  FROM security_badges b JOIN personnel p ON b.personnel_id = p.personnel_id
                  ORDER BY b.badge_id''')
    badges_list = cur.fetchall()
    cur.close()
    conn.close()
    return render_template('badges.html', badges=badges_list)

# --- Просмотр справочника сотрудников (department_employee) ---
@app.route('/directory')
@require_role('department_employee')
def directory():
    """
    Просмотр справочника сотрудников. Только для обычного сотрудника.
    """
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute('SELECT * FROM v_employee_directory ORDER BY full_name')
    directory_list = cur.fetchall()
    cur.close()
    conn.close()
    return render_template('directory.html', directory=directory_list)

# --- Просмотр внутренних документов (department_employee) ---
@app.route('/internal_docs')
@require_role('department_employee')
def internal_docs():
    """
    Просмотр внутренних документов. Только для обычного сотрудника.
    """
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute('SELECT * FROM v_internal_docs ORDER BY creation_date DESC')
    docs = cur.fetchall()
    cur.close()
    conn.close()
    return render_template('internal_docs.html', docs=docs)

if __name__ == '__main__':
    app.run(debug=True)
