import 'dart:io';

///性别枚举
enum NIMUserGender {
  ///未知性别
  NIMUserGenderUnknown,

  ///性别男
  NIMUserGenderMale,

  ///性别女
  NIMUserGenderFemale
}

class NIMUserInfoEntity {
  ///用户昵称
  String nickName;

  ///用户头像
  String avatarUrl;

  ///用户头像缩略图
  String thumbAvatarUrl;

  ///用户签名
  String sign;

  ///用户性别
  String gender;

  ///邮箱
  String email;

  ///生日
  String birth;

  ///电话号码
  String mobile;

  ///用户自定义扩展字段
  String ext;

  NIMUserInfoEntity(
      {this.nickName,
      this.avatarUrl,
      this.thumbAvatarUrl,
      this.sign,
      this.gender,
      this.email,
      this.birth,
      this.mobile,
      this.ext});

  Map toJson() {
    return {
      'nickName': nickName,
      'avatarUrl': avatarUrl,
      'thumbAvatarUrl': thumbAvatarUrl,
      'sign': sign,
      'gender': gender,
      'email': email,
      'birth': birth,
      'mobile': mobile,
      'ext': ext,
    };
  }

  NIMUserInfoEntity.fromJson(Map<dynamic, dynamic> json)
      : nickName = json['nickName'],
        avatarUrl = json['avatarUrl'],
        thumbAvatarUrl = json['thumbAvatarUrl'],
        sign = json['sign'],
        gender = json['gender'],
        email = json['email'],
        birth = json['birth'],
        mobile = json['mobile'],
        ext = json['ext'];
}

///云信用户
class NIMUserEntity {
  ///用户Id
  String userId;

  ///备注名，长度限制为128个字符。
  String alias;

  ///扩展字段
  String ext;

  ///服务器扩展字段,该字段只能由服务器进行修改，客户端只能读取
  String serverExt;

  ///用户资料，仅当用户选择托管信息到云信时有效
  NIMUserInfoEntity userInfo;

  NIMUserEntity(
      {this.userId, this.alias, this.ext, this.serverExt, this.userInfo});

  NIMUserEntity.fromJson(Map<dynamic, dynamic> map)
      : this(
          userId: Platform.isIOS ? map['userId'] : map['account'],
          alias: Platform.isIOS ? map['alias'] : map['name'],
          ext: Platform.isIOS ? map['ext'] : map['extensionMap'].toString(),
          serverExt: map['serverExt'],
          userInfo: Platform.isIOS
              ? NIMUserInfoEntity.fromJson(map['userInfo'])
              : NIMUserInfoEntity(
                  nickName: map['name'],
                  avatarUrl: map['avatar'],
                  sign: map['signature'],
                  email: map['email'],
                  mobile: map['mobile'],
                  gender: map['genderEnum'],
                  birth: map['birthday'],
                  ext: map['extensionMap'].toString()),
        );

  // Currently not used
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'alias': alias,
      'ext': ext,
      'serverExt': serverExt,
      'userInfo': userInfo,
    };
  }
}
