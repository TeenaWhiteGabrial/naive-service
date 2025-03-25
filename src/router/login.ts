import authController from "../controllers/auth";
import koaRouter from "koa-router";
import { methodType } from "../type/enum"

const router = new koaRouter(
  {
    prefix: '/spc'
  }
);
/** 开放接口，不需要token */

const routerList = [
  /** 管理端/登录 */
  {
    path: `/auth/login`,
    method: methodType.POST,
    action: authController.checkAuth,
  },
]

routerList.forEach((route) => {
  router[route.method](route.path, route.action)
})
export default router;
