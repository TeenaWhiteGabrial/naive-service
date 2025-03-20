import { Context, Next } from "koa";
import { CODE } from "../config/code";
import { decodeToken } from "../utils/util";
import { getRequestType } from "../type/global";
import { PLATFORM } from "../config/constant";
import user from "../controllers/user";
// import { getUserInfoByIdService } from "../services/user";

/** 校验Token是否合法 */
export const jwtMiddlewareDeal = async (ctx: Context, next: Next) => {
  const token = ctx.request.headers.authorization;
  if (typeof token === "string") {
    try {
      const userId = decodeToken(token);

      if (userId === null || userId === undefined) {
        throw CODE.tokenFailed;
      }
      else {
        ctx.userId = userId;
      }
    } catch (error) {
      throw CODE.tokenFailed;
    }
  } else {
    throw CODE.tokenFailed;
  }
  return next();
};

// 校验header中platform是否合法
export const platformMiddlewareDeal = async (ctx: Context, next: Next) => {
  const { platform } = ctx.request.headers as getRequestType;
  // @ts-ignore
  if (!PLATFORM[platform]) {
    throw CODE.missingParameters;
  }
  ctx.platform = platform;
  return next();
};
