library first_am.globals;

class AuthUser{
  String key = '';
  String name = '';

  AuthUser();

  void setKey({key}){
    this.key = key;
  }

  void setName({name}){
    this.name = name;
  }
}

AuthUser usuario = AuthUser();
