-- ============================================================================
--  V016__hide-demo-menus.sql
--
--  用途：隐藏「上游演示 / 示例」菜单（**只改 visible，可逆**，不删数据）。
--
--  为什么用隐藏而不是删除：
--    · 隐藏父菜单即隐藏整棵子树，前端立刻干净，零代码改动；
--    · 完全可逆 —— 把 visible 改回 b'1' 即可恢复（演示/联调时还会用到）；
--    · 客户项目里「看不到多余功能」就够了，不必为洁癖删数据。
--    这与 _runtime\apply-modules.ps1 的模块开关用的是同一套机制与理由。
--
--  本次隐藏的 2 棵子树（2026-10-07 实测，共 7 个节点）：
--    id=3   OA 示例      （挂在工作流程 /bpm 下，是上游 BPM 请假流程的演示入口）
--      └ id=115 请假查询  →  bpm/oa/leave/index
--          └ id=116 请假流程查询、id=117 请假申请创建（按钮）
--    id=349 支付示例     （挂在支付管理 /pay 下，是上游支付接入示例）
--      └ id=583 支付&退款案例   →  pay/demo/order/index
--      └ id=584 余额转账案例    →  pay/demo/withdraw/index
--
--  注意：**目录节点(type=1)的 component 前端不用于渲染**（MenuTypeEnum: DIR(1)/MENU(2)/BUTTON(3)），
--        所以 id=349 的 component=pay/demo/index 没有对应文件**不算缺失** —— 上游本身就不发布它，
--        真正渲染的是它的两个子页，那两个视图文件都存在。实测 /pay/demo/order 页面完全正常。
--
--  可重复执行：是（纯 UPDATE，幂等）
-- ============================================================================

SET NAMES utf8mb4;

-- 1) OA 示例（工作流程下）
UPDATE `system_menu` SET `visible` = b'0'
 WHERE `deleted` = b'0' AND `id` IN (3, 115, 116, 117);

-- 2) 支付示例（支付管理下）
UPDATE `system_menu` SET `visible` = b'0'
 WHERE `deleted` = b'0' AND `id` IN (349, 583, 584);
