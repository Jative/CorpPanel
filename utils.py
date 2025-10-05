from werkzeug.security import check_password_hash, generate_password_hash

def hash_password(password):
    """
    Хеширует пароль для хранения в БД.
    :param password: Обычный пароль
    :return: Хеш пароля
    """
    return generate_password_hash(password)

def verify_password(hash, password):
    """
    Проверяет соответствие пароля и хеша.
    :param hash: Хеш пароля
    :param password: Введённый пароль
    :return: True/False
    """
    return check_password_hash(hash, password)
