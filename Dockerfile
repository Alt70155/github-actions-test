FROM centos:7

RUN yum -y update && \
    yum -y install java-1.8.0-openjdk maven wget unzip openssh-server openssh-clients initscripts httpd

# rootのパスワード指定(root:の後が設定したパスワード・今回のパスワードはpassword)
# 本番環境は公開鍵認証方式だが、ローカル環境で公開鍵にしてしまうと鍵の受け渡しやtask-runnerとの連携が大変になるため、
# とりあえずローカルではパスワード認証にしておく。
RUN echo 'root:password' | chpasswd

# SSH接続の為の設定
RUN sed -ri 's/^#PermitRootLogin yes/PermitRootLogin yes/' /etc/ssh/sshd_config

# 公開鍵登録、使わなくても登録しておかなければいけない。sshdに必要
RUN ssh-keygen -t rsa -N "" -f /etc/ssh/ssh_host_rsa_key
RUN ssh-keygen -t ecdsa -N "" -f /etc/ssh/ssh_host_ecdsa_key
RUN ssh-keygen -t ed25519 -N "" -f /etc/ssh/ssh_host_ed25519_key

# locale
RUN localedef -f UTF-8 -i ja_JP ja_JP.UTF-8
ENV LANG="ja_JP.UTF-8" \
    LANGUAGE="ja_JP:ja" \
    LC_ALL="ja_JP.UTF-8"

# sshdとjbossの自動起動を有効化
# ここでは起動できないので、startではなくenableにして、コンテナが立ち上がったタイミングで起動させる。
RUN systemctl enable sshd
RUN systemctl enable httpd

# CMDでsbin/init(systemd)を起動しないとsystemctlが使えない
CMD ["/sbin/init"]
