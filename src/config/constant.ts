// 环境变量配置
import { anyKeyObject } from "../type/global";

export const ENV = {
  development: "development",
  production: "production",
};

// mongoDB配置
export const DATABASE = {
  // 本地环境
  development: {
    dbName: "StarPeaceCompany",
    user: "topaz",
    password: "ipcMasterTopazzz",
    host: "39.105.212.130",
    port: 27017,
  },

  // 阿里云环境
  production: {
    dbName: "StarPeaceCompany",
    user: "topaz",
    password: "ipcMasterTopazzz",
    host: "39.105.212.130",
    port: 27017,
  },
};

// jsonwebtoken-jwt配置
export const JWT = {
  secret: "x", //密钥
  expires: 60 * 60 * 24 * 30, // 30天
};

// 平台Map
export const PLATFORM = {
  wxMini: "微信小程序",
  wxH5: "微信H5",
  webH5: "webH5",
  dyMini: "抖音小程序",
  ksMini: "快手小程序",
  qqMini: "QQ小程序",
};


// 全局参数
export const FIXED_KEY = {
  port: 9090,
};

// 七牛上传参数
export const QINIU = {
  accessKey: 'ONiGLrLxZ2zTRQVDECDAy57fMz4cLGon93hrp1ca',
  secretKey: 'mOIIU8JaAeTp-JWnacVhQTEg9o8BAySmKlAuBLO4',
  bucketName: 'topazzz',
  uploadUrl: 'http://qiniu.tenmagabrielwhite.cn', // 空间地址
  expires: 7200, // 凭证有效期，单位是秒
}

// 日志参数
