import authController from "../controllers/auth";
import userController from "../controllers/user";
import qiniuController from "../controllers/qiniu";
import timeController from "../controllers/time"
import aiController from "../controllers/ai"

import koaRouter from "koa-router";
import { methodType } from "../type/enum"
import { jwtMiddlewareDeal, platformMiddlewareDeal } from "../middleware/jwt";

const router = new koaRouter({
  prefix: '/spc'
});
/** 管理端，需要Token的相关接口 */
router.use(jwtMiddlewareDeal);

const routerList = [
  /** 登出 */
  {
    path: `/private/auth/logout`,
    method: methodType.POST,
    action: authController.logout,
  },
  /** 获取简单用户信息 */
  {
    path: `/user/info/simple`,
    method: methodType.GET,
    action: userController.getSimpleUser,
  },
  /** 获取全部用户资料 */
  {
    path: `/user/info/all`,
    method: methodType.POST,
    action: userController.getAllUser,
  },
  /** 获取路由菜单 */
  {
    path: `/user/menus`,
    method: methodType.POST,
    action: userController.getMenus,
  },
  /** 获取用户列表 */
  {
    path: `/user/list`,
    method: methodType.POST,
    action: userController.getUserList,
  },
  /** 修改用户资料 */
  {
    path: `/user/update/:userid`,
    method: methodType.POST,
    action: userController.updateUser,
  },
  /** 新建用户 */
  {
    path: `/user/add`,
    method: methodType.POST,
    action: userController.addUser,
  },
  /** 删除用户 */
  {
    path: `/user/delete/:userId`,
    method: methodType.POST,
    action: userController.deleteUser,
  },
  /** 修改密码 */
  {
    path: `/user/changePassword`,
    method: methodType.POST,
    action: userController.changePassword,
  },
  /** 重置密码 */
  {
    path: `/user/resetPassword`,
    method: methodType.POST,
    action: userController.resetPassword,
  },

  /** 获取角色列表 */
  {
    path: `/role/list`,
    method: methodType.POST,
    action: userController.getRoleList,
  },
  /** 新建角色 */
  {
    path: `/role/add`,
    method: methodType.POST,
    action: userController.addRole,
  },
  /** 修改角色 */
  {
    path: `/role/update`,
    method: methodType.POST,
    action: userController.updateRole,
  },
  /** 删除角色 */
  {
    path: `/role/delete/:roleCode`,
    method: methodType.POST,
    action: userController.deleteRole,
  },
  /** 获取菜单树 */
  {
    path: `/permission/menu/tree`,
    method: methodType.GET,
    action: userController.getMenuTree,
  },
  /** 获取按钮 */
  {
    path: `/permission/button/:permissionId`,
    method: methodType.GET,
    action: userController.getButtons,
  },
  /** 新增资源 */
  {
    path: `/permission/add`,
    method: methodType.POST,
    action: userController.addPermission,
  },
  /** 修改资源 */
  {
    path: `/permission/update`,
    method: methodType.POST,
    action: userController.updatePermission,
  },
  /** 删除资源 */
  {
    path: `/permission/delete/:permissionId`,
    method: methodType.POST,
    action: userController.deletePermission,
  },

  /** 七牛云获取上传凭证 */
  {
    path: `/upload/getUploadToken`,
    method: methodType.GET,
    action: qiniuController.getUploadToken,
  },
  /** 获取下一个休息日的信息 */
  {
    path: `/holiday/nextHoliday/:date`,
    method: methodType.GET,
    action: timeController.getNextHolidayInfo
  },
  /** 使用AI获取古诗词 */
  {
    path: `/ai/getVerse`,
    method: methodType.POST,
    action: aiController.getVerse
  },
]

routerList.forEach((route) => {
  router[route.method](route.path, route.action)
})
export default router;
