export const CODE = {
  /** 业务错误码 */
  buinessError: {
    code: 400,
    msg: "业务错误"
  },
  // 普通错误code 均为 -1；前端直接捕获-1的错误 抛出
  success: { code: 0, msg: "success" },
  missingParameters: {
    code: -1,
    msg: "缺少参数"
  },
  tokenFailed: { code: 1, msg: "token校验失败" },
  loginFailer: {
    code: -1,
    msg: "用户名密码不匹配"
  },
  illegalRequest: { code: 4, msg: "非法请求", key: "illegalRequest" },
  operateFail: {
    code: 400,
    msg: '操作失败'
  },
  serverError: (message: string = '服务器内部错误') => ({
    code: 500,
    msg: message
  })
};

