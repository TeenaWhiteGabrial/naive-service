import Koa from "koa";
import { logger } from "../log/log";
import { CODE } from "../config/code";
import { Context } from "koa";

// 这个middleware用于将ctx.result中的内容最终回传给客户端
export const responseHandler = (ctx: Context) => {
  if (ctx.body !== undefined) {
    ctx.type = "json";
    if (ctx.body === null) {
      ctx.body = null;
    } else {
      ctx.body = {
        code: CODE.success.code,
        data: ctx.body,
        msg: CODE.success.msg,
      };
    }
  }
};

// 这个middleware处理在其它middleware中出现的异常,我们在next()后面进行异常捕获，出现异常直接进入这个中间件进行处理
export const errorHandler = (ctx: Koa.Context, next: Koa.Next) => {
  return next().catch((err: { code: number; message: any }) => {
    if (typeof err === "object") {
      ctx.body = err;
    } else {
      ctx.body = {
        code: -1,
        data: null,
        msg: err,
      };
    }

    logger.error(err);

    // 保证返回状态是 200
    ctx.status = 200;

    return Promise.resolve();
  });
};
