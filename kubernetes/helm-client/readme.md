# 构建cmp-helm-client
  关于构建helm客户端镜像的Dockerfile及其他依赖资源
## 资源
  |文件资源|说明|
  |:-------------|:-----------|
  |helm-push.tar| helm push 插件安装包|
  |Dockerfile|镜像构建文件|
  |helm-script/env.sh|测试用的环境变量信息|
  |helm-script/entrypoint.sh|启动脚本|
## 环境变量说明
  |环境变量名|说明|适用范围|
  |:-------------------|:--------------------------------------------------|:----------------------------|
  |APP_NAME|应用名|helm部署/卸载|
  |APP_NAMESPACE|kubernetes部署命名空间|helm部署卸载，可以不指定，将参考资源文件或者默认default|
  |CHART_VERSION|chart包版本|helm部署 可以不指定默认最新版本|
  |CHART_NAME|chart包名称|必须指定，适用所有操作|
  |CHART_VALUES|设置部署应用时的值，格式为CHART_VALUES="a=b,c=d"|helm部署|
  |HARBOR_USERNAME|harbor用户名|helm部署，上传chart|
  |HARBOR_PASSWORD|harbor用户密码|同username一起使用|
  |HARBOR_SERVER|harbor服务地址，避免使用域名，http://或者https://开头|helm部署，上传chart|
  |HARBOR_PROJECT|harbor项目名称，上传下拉chart包位置|helm部署，上传chart|
  |HARBOR_CA|harbor证书字符串，不需要证书头尾标识|只有当harbor服务为https的适用需要指定，上传chart|
  |KUBE_CA_DATA|kubernetes证书信息|helm部署卸载|
  |KUBE_API_SERVER|kubernetes apiserver地址 避免用域名|helm部署卸载|
  |KUBE_TOKEN|kubernetes凭据|helm部署卸载|

## 容器启动命令
* （默认）sh 用于启动容器，有前台进程挂起
* install 安装部署应用，相关参数取环境变量，无前台进程挂起，用于执行任务
* uninstall 卸载应用，相关参数取环境变量，无前台进程挂起，用于执行任务
* push 上传chart包到harbor，相关参数取环境变量，无前台进程挂起，用户执行任务
* helm [command] [flags] helm原生命令，helm相关参数需要自行指定，无前台进程挂起，用于执行任务