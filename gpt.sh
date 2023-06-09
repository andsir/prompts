#!/bin/bash

show_menu() {
    echo "请选择一个选项:更新代码后要更新prompts和masks"
    echo "1. 安装 azure-openai-proxy"
    echo "2. 安装 ChatGPT-Next-Web"
    echo "3. 卸载 ChatGPT-Next-Web"
    echo "4. 查看 ChatGPT-Next-Web 状态"
    echo "5. 更新 prompts (github源)"
    echo "6. 更新 masks (github源)"
    echo "7. 退出"
    echo "8. 更新 ChatGPT-Next-Web"
    echo "9. 修改环境变量"

}

install_azure-openai-proxy() {
     echo "安装 azure-openai-proxy..."
     docker run -d -p 3500:3000 scalaone/azure-openai-proxy
}

install_ChatGPT-Next-Web() {
    echo "安装 ChatGPT-Next-Web..."
    
    cd ~ || { echo -e "\033[31m进入根目录失败，请检查后重试。\033[0m"; return; }
    git clone https://github.com/Yidadaa/ChatGPT-Next-Web.git || { echo -e "\033[31m拉取源码失败，请检查后重试。\033[0m"; return; }
    cd ~/ChatGPT-Next-Web/scripts || { echo -e "\033[31m进入目录失败，请检查后重试。\033[0m"; return; }
    rm -rf fetch-prompts.mjs || { echo -e "\033[31m删除 fetch-prompts 失败，请检查后重试。\033[0m"; return; }
    cd ~/ChatGPT-Next-Web/public || { echo -e "\033[31m进入目录失败，请检查后重试。\033[0m"; return; }
    rm -rf prompts.json.bak
    mv prompts.json prompts.json.bak
    curl -f -s -o prompts.json https://raw.githubusercontent.com/andsir/stuff/main/prompts.json || { echo -e "\033[31m拉取 prompts 失败，请检查后重试。\033[0m"; mv prompts.json.bak prompts.json; return; }
    cd ~/ChatGPT-Next-Web/app/masks || { echo -e "\033[31m进入目录失败，请检查后重试。\033[0m"; return; }
    rm -rf cn.ts.bak
    mv cn.ts cn.ts.bak
    rm -rf en.ts.bak
    mv en.ts en.ts.bak
    curl -f -s -o cn.ts https://raw.githubusercontent.com/andsir/stuff/main/cn.ts || { echo -e "\033[31m拉取 cn.ts 失败，请检查后重试。\033[0m"; mv cn.ts.bak cn.ts; mv en.ts.bak en.ts; return; }
    curl -f -s -o en.ts https://raw.githubusercontent.com/andsir/stuff/main/en.ts || { echo -e "\033[31m拉取 en.ts 失败，请检查后重试。\033[0m"; mv cn.ts.bak cn.ts; mv en.ts.bak en.ts; return; }
    cd ~/ChatGPT-Next-Web || { echo -e "\033[31m进入目录失败，请检查后重试。\033[0m"; return; }
     read -p "请输入Azure转换的KEY，格式为 AZURE_RESOURCE_ID:AZURE_MODEL_DEPLOYMENT:AZURE_API_KEY:AZURE_API_VERSION  " azureproxykey

if [ -z "$azureproxykey" ]; then
    echo -e "\033[31mKEY不能为空。\033[0m"
    return
fi

    cat >/root/ChatGPT-Next-Web/.env.local<<-EOF
OPENAI_API_KEY="$azureproxykey"
CODE=kinnkonnNO.1
BASE_URL=http://127.0.0.1:3500
EOF

    cat >/etc/systemd/system/chatgpt.service<<-EOF
[Unit]
Description=ChatGPT-Next-Web
After=network.target

[Service]
ExecStart=/usr/bin/yarn dev
WorkingDirectory=/root/ChatGPT-Next-Web
Restart=always
User=root

[Install]
WantedBy=multi-user.target

EOF
    cd ~/ChatGPT-Next-Web || { echo -e "\033[31m进入目录失败，请检查后重试。\033[0m"; return; }
    yarn install
    systemctl daemon-reload
    systemctl enable chatgpt.service
    systemctl start chatgpt
}

update_ChatGPT-Next-Web() {
    cd ~/ChatGPT-Next-Web
    git pull
    
}

uninstall_ChatGPT-Next-Web() {
    systemctl stop chatgpt
    systemctl disable chatgpt
    rm -rf /etc/systemd/system/chatgpt.service
    systemctl daemon-reload
    cd ~
    rm -rf ChatGPT-Next-Web
}

status_ChatGPT-Next-Web() {
    systemctl status chatgpt
}

update_prompts() {
    cd ~/ChatGPT-Next-Web/public || { echo -e "\033[31m进入目录失败，请检查后重试。\033[0m"; return; }
    rm -rf prompts.json.bak
    mv prompts.json prompts.json.bak
    curl -f -s -o prompts.json https://raw.githubusercontent.com/andsir/stuff/main/prompts.json || { echo -e "\033[31m拉取 prompts 失败，请检查后重试。\033[0m"; mv prompts.json.bak prompts.json; return; }
}

update_masks() {
    cd ~/ChatGPT-Next-Web/app/masks || { echo -e "\033[31m进入目录失败，请检查后重试。\033[0m"; return; }
    rm -rf cn.ts.bak
    mv cn.ts cn.ts.bak
    rm -rf en.ts.bak
    mv en.ts en.ts.bak
    curl -f -s -o cn.ts https://raw.githubusercontent.com/andsir/stuff/main/cn.ts || { echo -e "\033[31m拉取 cn.ts 失败，请检查后重试。\033[0m"; mv cn.ts.bak cn.ts; mv en.ts.bak en.ts; return; }
    curl -f -s -o en.ts https://raw.githubusercontent.com/andsir/stuff/main/en.ts || { echo -e "\033[31m拉取 en.ts 失败，请检查后重试。\033[0m"; mv cn.ts.bak cn.ts; mv en.ts.bak en.ts; return; }
}
change_env() {
    cd ~/ChatGPT-Next-Web
    nano .env.local
}

while true; do
    show_menu
    read -p "请输入选项数字：" choice
case $choice in
    1) install_azure-openai-proxy;;
    2) install_ChatGPT-Next-Web;;
    3) uninstall_ChatGPT-Next-Web;;
    4) status_ChatGPT-Next-Web;;
    5) update_promots;;
    6) update_masks;;
    7) exit;;
    8) update_ChatGPT-Next-Web;;
    9) change_env;;
    
    *) echo -e "\033[31m无效选项\033[0m";;
esac
done
