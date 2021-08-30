# verify env params
verify_app_name(){
if [ -z ${APP_NAME} ];then
echo "环境变量:APP_NAME[应用名称]未设置."
exit 1
fi
}
verify_chart_name(){
if [ -z ${CHART_NAME} ];then
echo "环境变量:CHART_NAME[chart应用模板名称]未设置."
exit 1
fi
}
verify_namespace(){
if [ -z ${APP_NAMESPACE} ];then
APP_NAMESPACE="default"
fi
}
verify_harbor_server(){
if [ -z ${HARBOR_SERVER} ];then
echo "环境变量:HARBOR_SERVER[harbor服务地址，以http或者https开始]未设置."
exit 1
fi
}
verify_harbor_project(){
if [ -z ${HARBOR_PROJECT} ];then
echo "环境变量:HARBOR_PROJECT[harbor项目名称]未设置."
exit 1
fi
}
verify_harbor_ca(){
if [ -z ${HARBOR_CA} ];then
echo "环境变量:HARBOR_CA[harbor证书字符串，不含头尾标识]未设置"
exit 1
fi
}
verify_kube_token(){
if [ -z ${KUBE_TOKEN} ];then
echo "环境变量:KUBE_TOKEN[kubernetes认证凭据]未设置."
exit 1
fi
}
verify_kube_api_server(){
if [ -z ${KUBE_API_SERVER} ];then
echo "环境变量:KUBE_API_SERVER[kubernetes apiserver服务地址，以http或者https开始]未设置."
exit 1
fi
}
verify_kube_ca_data(){
if [ -z ${KUBE_CA_DATA} ];then
echo "环境变量:KUBE_CA_DATA[kubernetes证书字符串，不含头尾标识]未设置"
exit 1
fi
}
# init .kube/config 
init_kube_config(){
if [ ! -e /root/.kube  ];then
mkdir /root/.kube
fi
verify_kube_token
verify_kube_api_server
verify_kube_ca_data
tokenbase64=`echo ${KUBE_TOKEN}|base64 -d`
echo -e "apiVersion: v1\nclusters: \n- cluster:\n    certificate-authority-data: ${KUBE_CA_DATA}\n    server: ${KUBE_API_SERVER}\n  name: custom-cluster\ncontexts:\n- context:\n    cluster: custom-cluster\n    user: custom\n  name: custom-context\ncurrent-context: custom-context\nkind: Config\nusers:\n- name: custom\n  user:\n    token: ${tokenbase64}" > /root/.kube/config
}
# helm install
install(){
helm install ${APP_NAME} \
      `[ ${CHART_VALUES} ] && echo "--set ${CHART_VALUES}"` \
      `[ ${HARBOR_USERNAME} ] && echo "--username=${HARBOR_USERNAME}"`  \
      `[ ${HARBOR_PASSWORD} ] && echo "--password=${HARBOR_PASSWORD}"` \
      `[ ${CHART_VERSION} ] && echo "--version=${CHART_VERSION}"`    \
      --namespace=${APP_NAMESPACE} \
      --repo=${HARBOR_SERVER}/chartrepo/${HARBOR_PROJECT} \
      --insecure-skip-tls-verify \
      ${CHART_NAME}
}
# helm push
push(){
verify_harbor_server
if [[ ${HARBOR_SERVER} =~ ^https.* ]];then
   verify_harbor_ca
fi
# input ca data to ca.crt
echo "-----BEGIN CERTIFICATE-----" > ca.crt 
for n in ${HARBOR_CA};do
   echo $n >> ca.crt
done
echo "-----END CERTIFICATE-----" >> ca.crt
helm push ${CHART_NAME} \
     --insecure ${HARBOR_SERVER}/chartrepo/${HARBOR_PROJECT}/ \
     `[[ "${HARBOR_SERVER}" =~ "^https.*" ]] && echo "--ca-file ca.crt"` \
     `[ ${HARBOR_USERNAME} ] && echo "--username=${HARBOR_USERNAME}"`\
     `[ ${HARBOR_PASSWORD} ] && echo "--password=${HARBOR_PASSWORD}"`
}
#helm create 
create(){
helm create ${CHART_NAME}
}
#helm uninstall
uninstall(){
helm uninstall ${APP_NAME} 
}
if [ -z "$1" ];then
   echo "common actions [all parameters are in the form of environmental variables]"
   echo "- push: push a chart to repo"
   echo "- install:  upload the chart to Kubernetes"
   echo "- uninstall: uninstall the chart form kubernetes"
   echo "- create: create a chart"
   echo "- helm: helm common actions,Use helm [command] --help for more information about a command"
   echo "example: "
   echo "./entrypoint.sh install"
   echo "./entrypornt.sh helm create helloworld"
   sh
else
   case $1 in
   "install")
        init_kube_config
        install
        ;;
   "uninstall")
        init_kube_config
        uninstall
        ;;
   "push")
        push
        ;;
   "create")
        create
        ;;
   "helm")
        $@
        ;;
   *)
        echo "wrong command"
        exit 1
        ;;
   esac
fi
