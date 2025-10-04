SELECT setval('personnel_personnel_id_seq', (SELECT MAX(personnel_id) FROM personnel));

-- Задание I --
CREATE TABLE IF NOT EXISTS divisions (
    division_id SERIAL PRIMARY KEY,
    division_name VARCHAR(100) NOT NULL,
    director_id INTEGER
    -- FK добавим позже, после создания personnel
);

CREATE TABLE IF NOT EXISTS personnel (
    personnel_id SERIAL PRIMARY KEY,
    full_name VARCHAR(255) NOT NULL,
    division_id INTEGER REFERENCES divisions(division_id) ON DELETE SET NULL,
    role VARCHAR(100) NOT NULL,
    join_date DATE NOT NULL,
    personal_email VARCHAR(255) UNIQUE NOT NULL,
    contact_number VARCHAR(20)
);

-- Добавляем FK для director_id после создания personnel
ALTER TABLE divisions ADD CONSTRAINT fk_director
    FOREIGN KEY (director_id) REFERENCES personnel(personnel_id) ON DELETE SET NULL;

CREATE TABLE IF NOT EXISTS security_badges (
    badge_id SERIAL PRIMARY KEY,
    personnel_id INTEGER UNIQUE REFERENCES personnel(personnel_id) ON DELETE CASCADE,
    issuance_date DATE NOT NULL,
    is_valid BOOLEAN DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS classified_files (
    file_id SERIAL PRIMARY KEY,
    file_name VARCHAR(255) NOT NULL,
    author_id INTEGER REFERENCES personnel(personnel_id) ON DELETE SET NULL,
    creation_date DATE NOT NULL,
    file_content TEXT,  -- Или путь к файлу, например VARCHAR(255)
    security_level VARCHAR(20) CHECK (security_level IN ('Public', 'Internal', 'Confidential', 'Strictly'))
);

-- Индексы для оптимизации
CREATE INDEX idx_personnel_division ON personnel(division_id);
CREATE INDEX idx_files_author ON classified_files(author_id);
CREATE INDEX idx_badges_personnel ON security_badges(personnel_id);





-- Задание II --
SET search_path TO public;

-- Добавляем поле work_phone в таблицу personnel
ALTER TABLE personnel ADD COLUMN IF NOT EXISTS work_phone VARCHAR(20);

-- 1. Наполнение таблицы divisions
INSERT INTO divisions (division_id, division_name, director_id) VALUES
(1, 'IT', NULL),
(2, 'Информационная безопасность', NULL),
(3, 'Бухгалтерия', NULL),
(4, 'Отдел кадров', NULL),
(5, 'Маркетинг', NULL);

-- 2. Наполнение таблицы personnel
INSERT INTO personnel (personnel_id, full_name, division_id, role, join_date, personal_email, contact_number, work_phone) VALUES
(1, 'Иван Петров', 1, 'Ведущий разработчик', '2023-01-15', 'ivan.petrov@example.com', '+79123456789', '+74951230001'),
(2, 'Анна Сидорова', 1, 'Разработчик', '2023-03-10', 'anna.sidorova@example.com', '+79123456790', '+74951230002'),
(3, 'Михаил Иванов', 1, 'Сисадмин', '2022-06-20', 'mikhail.ivanov@example.com', '+79123456791', '+74951230003'),
(4, 'Елена Кузнецова', 1, 'DevOps-инженер', '2024-02-01', 'elena.kuznetsova@example.com', '+79123456792', '+74951230004'),
(5, 'Дмитрий Смирнов', 1, 'Тестировщик', '2023-11-05', 'dmitry.smirnov@example.com', '+79123456793', '+74951230005'),
(6, 'Ольга Васильева', 2, 'Аналитик безопасности', '2022-09-12', 'olga.vasilyeva@example.com', '+79123456794', '+74951230006'),
(7, 'Алексей Николаев', 2, 'Специалист по ИБ', '2023-04-18', 'alexey.nikolaev@example.com', '+79123456795', '+74951230007'),
(8, 'Мария Попова', 2, 'Пентестер', '2024-01-25', 'maria.popova@example.com', '+79123456796', '+74951230008'),
(9, 'Сергей Морозов', 2, 'Сетевой инженер', '2023-07-30', 'sergey.morozov@example.com', '+79123456797', '+74951230009'),
(10, 'Татьяна Лебедева', 2, 'Специалист по compliance', '2022-12-01', 'tatyana.lebedeva@example.com', '+79123456798', '+74951230010'),
(11, 'Наталья Козлова', 3, 'Главный бухгалтер', '2021-05-10', 'natalya.kozlova@example.com', '+79123456799', '+74951230011'),
(12, 'Виктор Соколов', 3, 'Бухгалтер', '2023-02-15', 'viktor.sokolov@example.com', '+79123456800', '+74951230012'),
(13, 'Ирина Белова', 3, 'Финансовый аналитик', '2022-08-20', 'irina.belova@example.com', '+79123456801', '+74951230013'),
(14, 'Павел Зайцев', 3, 'Бухгалтер', '2024-03-05', 'pavel.zaytsev@example.com', '+79123456802', '+74951230014'),
(15, 'Екатерина Романова', 3, 'Аудитор', '2023-09-10', 'ekaterina.romanova@example.com', '+79123456803', '+74951230015'),
(16, 'Андрей Волков', 4, 'HR-менеджер', '2022-04-01', 'andrey.volkov@example.com', '+79123456804', '+74951230016'),
(17, 'Светлана Орлова', 4, 'Рекрутер', '2023-06-15', 'svetlana.orlova@example.com', '+79123456805', '+74951230017'),
(18, 'Юлия Фомина', 4, 'Специалист по кадрам', '2024-02-20', 'yulia.fomina@example.com', '+79123456806', '+74951230018'),
(19, 'Роман Григорьев', 4, 'Тренинг-менеджер', '2023-10-01', 'roman.grigoryev@example.com', '+79123456807', '+74951230019'),
(20, 'Валерия Егорова', 4, 'HR-аналитик', '2022-11-10', 'valeria.egorova@example.com', '+79123456808', '+74951230020'),
(21, 'Константин Лебедев', 5, 'Маркетолог', '2023-01-20', 'konstantin.lebedev@example.com', '+79123456809', '+74951230021'),
(22, 'Анастасия Миронова', 5, 'SMM-менеджер', '2023-05-15', 'anastasia.mironova@example.com', '+79123456810', '+74951230022'),
(23, 'Игорь Степанов', 5, 'Копирайтер', '2024-01-10', 'igor.stepanov@example.com', '+79123456811', '+74951230023'),
(24, 'Ксения Фёдорова', 5, 'Дизайнер', '2023-08-05', 'ksenia.fedorova@example.com', '+79123456812', '+74951230024'),
(25, 'Артём Беляев', 5, 'Аналитик данных', '2022-12-20', 'artem.belyaev@example.com', '+79123456813', '+74951230025'),
(26, 'Владимир Ковалёв', 1, 'Разработчик', '2023-03-01', 'vladimir.kovalev@example.com', '+79123456814', '+74951230026'),
(27, 'Оксана Жукова', 1, 'Тестировщик', '2024-04-10', 'oksana.zhukova@example.com', '+79123456815', '+74951230027'),
(28, 'Глеб Титов', 2, 'Специалист по ИБ', '2023-07-15', 'gleb.titov@example.com', '+79123456816', '+74951230028'),
(29, 'Марина Шестакова', 3, 'Бухгалтер', '2023-11-20', 'marina.shestakova@example.com', '+79123456817', '+74951230029'),
(30, 'Никита Королёв', 4, 'Рекрутер', '2024-05-01', 'nikita.korolev@example.com', '+79123456818', '+74951230030');

-- Обновляем director_id в divisions
UPDATE divisions SET director_id = 1 WHERE division_id = 1; -- Иван Петров (IT)
UPDATE divisions SET director_id = 6 WHERE division_id = 2; -- Ольга Васильева (ИБ)
UPDATE divisions SET director_id = 11 WHERE division_id = 3; -- Наталья Козлова (Бухгалтерия)
UPDATE divisions SET director_id = 16 WHERE division_id = 4; -- Андрей Волков (Отдел кадров)
UPDATE divisions SET director_id = 21 WHERE division_id = 5; -- Константин Лебедев (Маркетинг)

-- 3. Наполнение таблицы security_badges
INSERT INTO security_badges (badge_id, personnel_id, issuance_date, is_valid) VALUES
(1, 1, '2023-01-16', TRUE),
(2, 2, '2023-03-11', TRUE),
(3, 3, '2022-06-21', TRUE),
(4, 4, '2024-02-02', TRUE),
(5, 5, '2023-11-06', TRUE),
(6, 6, '2022-09-13', TRUE),
(7, 7, '2023-04-19', TRUE),
(8, 8, '2024-01-26', TRUE),
(9, 9, '2023-07-31', TRUE),
(10, 10, '2022-12-02', FALSE),
(11, 11, '2021-05-11', TRUE),
(12, 12, '2023-02-16', TRUE),
(13, 13, '2022-08-21', TRUE),
(14, 14, '2024-03-06', TRUE),
(15, 15, '2023-09-11', TRUE),
(16, 16, '2022-04-02', TRUE),
(17, 17, '2023-06-16', TRUE),
(18, 18, '2024-02-21', TRUE),
(19, 19, '2023-10-02', TRUE),
(20, 20, '2022-11-11', TRUE),
(21, 21, '2023-01-21', TRUE),
(22, 22, '2023-05-16', TRUE),
(23, 23, '2024-01-11', TRUE),
(24, 24, '2023-08-06', TRUE),
(25, 25, '2022-12-21', TRUE),
(26, 26, '2023-03-02', TRUE),
(27, 27, '2024-04-11', TRUE),
(28, 28, '2023-07-16', TRUE),
(29, 29, '2023-11-21', TRUE),
(30, 30, '2024-05-02', TRUE);

-- 4. Наполнение таблицы classified_files
INSERT INTO classified_files (file_id, file_name, author_id, creation_date, file_content, security_level) VALUES
(1, 'Код API v1.0', 1, '2023-02-01', 'REST API source code', 'Internal'),
(2, 'Отчёт по уязвимостям Q1', 6, '2023-03-15', 'Security audit report', 'Confidential'),
(3, 'План маркетинга 2024', 21, '2023-12-10', 'Marketing strategy', 'Public'),
(4, 'Схема инфраструктуры', 3, '2022-07-01', 'Network architecture', 'Strictly'),
(5, 'Руководство по DevOps', 4, '2024-02-15', 'CI/CD pipeline guide', 'Internal'),
(6, 'Финансовый отчёт 2023', 11, '2023-06-30', 'Financial statement', 'Confidential'),
(7, 'Код фронтенда', 2, '2023-04-01', 'React app source', 'Internal'),
(8, 'Патент на алгоритм', 1, '2023-05-20', 'Algorithm patent', 'Strictly'),
(9, 'Отчёт по тестированию', 5, '2023-11-10', 'QA report', 'Internal'),
(10, 'Политика GDPR', 10, '2023-01-15', 'Compliance policy', 'Public'),
(11, 'Бухгалтерский баланс', 12, '2023-03-01', 'Balance sheet', 'Confidential'),
(12, 'Код бэкенда', 26, '2023-04-15', 'Node.js backend', 'Internal'),
(13, 'План по ИБ 2024', 7, '2023-10-01', 'Security roadmap', 'Confidential'),
(14, 'Дизайн баннеров', 24, '2023-08-10', 'Banner designs', 'Public'),
(15, 'Руководство по HR', 16, '2022-05-01', 'HR manual', 'Internal'),
(16, 'Код ML-модели', 1, '2023-06-01', 'Machine learning code', 'Strictly'),
(17, 'Отчёт по SMM', 22, '2023-06-15', 'SMM analytics', 'Public'),
(18, 'Аудит сети', 9, '2023-08-01', 'Network audit', 'Confidential'),
(19, 'Тестовые сценарии', 27, '2024-04-20', 'Test cases', 'Internal'),
(20, 'Финансовый прогноз', 13, '2023-09-15', 'Financial forecast', 'Confidential'),
(21, 'Код микросервиса', 2, '2023-07-01', 'Microservice code', 'Internal'),
(22, 'Политика безопасности', 8, '2024-02-01', 'Security policy', 'Public'),
(23, 'Инфраструктурный аудит', 4, '2024-03-01', 'Infra audit', 'Strictly'),
(24, 'Код скрипта автоматизации', 3, '2022-08-01', 'Automation script', 'Internal'),
(25, 'План обучения', 19, '2023-10-15', 'Training plan', 'Internal');

-- 5. Создание представления v_employee_directory
CREATE OR REPLACE VIEW v_employee_directory AS
SELECT 
    p.full_name,
    d.division_name,
    p.role,
    p.work_phone
FROM personnel p
JOIN divisions d ON p.division_id = d.division_id;

-- 6. Создание представления v_internal_docs
CREATE OR REPLACE VIEW v_internal_docs AS
SELECT 
    f.file_id,
    f.file_name,
    f.author_id,
    p.full_name AS author_name,
    f.creation_date,
    f.security_level
FROM classified_files f
JOIN personnel p ON f.author_id = p.personnel_id
WHERE f.security_level IN ('Internal', 'Confidential', 'Strictly');





-- Задание III --
SET search_path TO public;

-- 1. Отзываем лишние привилегии у схемы public для безопасности
REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM PUBLIC;
REVOKE ALL ON ALL SEQUENCES IN SCHEMA public FROM PUBLIC;

-- 2. Создание ролей
CREATE ROLE hr_manager;
CREATE ROLE security_officer;
CREATE ROLE department_employee;

-- 3. Назначение привилегий для ролей
-- hr_manager: полный доступ к personnel и divisions
GRANT SELECT, INSERT, UPDATE, DELETE ON personnel TO hr_manager;
GRANT SELECT, INSERT, UPDATE, DELETE ON divisions TO hr_manager;
GRANT USAGE ON SCHEMA public TO hr_manager; -- Доступ к схеме

-- security_officer: только чтение для personnel и security_badges
GRANT SELECT ON personnel TO security_officer;
GRANT SELECT ON security_badges TO security_officer;
GRANT USAGE ON SCHEMA public TO security_officer;

-- department_employee: только чтение для представлений v_employee_directory и v_internal_docs
GRANT SELECT ON v_employee_directory TO department_employee;
GRANT SELECT ON v_internal_docs TO department_employee;
GRANT USAGE ON SCHEMA public TO department_employee;

-- 4. Создание пользователей и назначение ролей
CREATE USER anna_hr WITH PASSWORD 'secure_password_anna';
CREATE USER oleg_sec WITH PASSWORD 'secure_password_oleg';
CREATE USER ivan_emp WITH PASSWORD 'secure_password_ivan';

GRANT hr_manager TO anna_hr;
GRANT security_officer TO oleg_sec;
GRANT department_employee TO ivan_emp;

-- 5. Убедимся, что пользователи не имеют лишних привилегий
REVOKE ALL ON classified_files FROM hr_manager, security_officer, department_employee;
REVOKE ALL ON security_badges FROM hr_manager, department_employee;
REVOKE ALL ON personnel FROM department_employee;
REVOKE ALL ON divisions FROM security_officer, department_employee;





-- Задание IV --
SET search_path TO public;

-- Тест для anna_hr (роль hr_manager)
SET ROLE anna_hr;
SELECT CURRENT_USER;
-- Проверка доступа к personnel (должно работать)
SELECT * FROM personnel LIMIT 3;
-- Проверка доступа к divisions (должно работать)
SELECT * FROM divisions LIMIT 3;
-- Проверка доступа к security_badges (должна дать ошибку)
SELECT * FROM security_badges LIMIT 3;
-- Проверка доступа к classified_files (должна дать ошибку)
SELECT * FROM classified_files LIMIT 3;
RESET ROLE;

-- Тест для oleg_sec (роль security_officer)
SET ROLE oleg_sec;
SELECT CURRENT_USER;
-- Проверка доступа к personnel (должно работать)
SELECT * FROM personnel LIMIT 3;
-- Проверка доступа к security_badges (должно работать)
SELECT * FROM security_badges LIMIT 3;
-- Проверка доступа к divisions (должна дать ошибку)
SELECT * FROM divisions LIMIT 3;
-- Проверка доступа к v_internal_docs (должна дать ошибку)
SELECT * FROM v_internal_docs LIMIT 3;
RESET ROLE;

-- Тест для ivan_emp (роль department_employee)
SET ROLE ivan_emp;
SELECT CURRENT_USER;
-- Проверка доступа к v_employee_directory (должно работать)
SELECT * FROM v_employee_directory LIMIT 3;
-- Проверка доступа к v_internal_docs (должно работать)
SELECT * FROM v_internal_docs LIMIT 3;
-- Проверка доступа к personnel (должна дать ошибку)
SELECT * FROM personnel LIMIT 3;
-- Проверка доступа к classified_files (должна дать ошибку)
SELECT * FROM classified_files LIMIT 3;
RESET ROLE;