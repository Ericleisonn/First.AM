library first_am.globals;

class AuthUser{
  String key = '';
  String name = '';

  AuthUser();

  void setKey({key}){
    this.key = key;
  }
}

AuthUser usuario = AuthUser();
