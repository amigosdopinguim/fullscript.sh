#!/bin/bash
# ----------------------------------------------------------------------------
# fullscript.sh
# Uso: ./fullscript.sh
# Ex.: ./fullscript.sh
#
# Autor: Marcos da B. M. Oliveira <http://amigosdopinguim.blogspot.com.br/>
# Versão: 1
# Licença: GPL
# ----------------------------------------------------------------------------

# só iniciará o processo de estiver logado como ROOT
if [ "$USER" = "root" ] ; then
	echo "";
else
	echo -e "Você precisa ser root.\nAbortar.";
	exit 0;
fi

# função para atualizar o sources.list
atualizar(){
	# com opção menos -y caso precise de interação
	apt-get update -y
	apt-get upgrade -y
	apt-get update -y
}

# função para alterar o sources.list
novalista(){

	# backup do sources.list
	cp /etc/apt/sources.list /etc/apt/bkp.sources.list
	
	# variável que pega o nome da distribuiçao, poderia ser tb: uname -a | awk '{print $2}', mas a sáida sera em minúsculo (debian)
	distro="$(cat /etc/issue | awk '{print $1}' | sed '/^$/d')";
	
	# pega a versão da distro, se pôr f2 no cut pega a variação, ex.: 7.(2), 6.(5), 12.(10), ...
	versao="$(cat /etc/issue | awk '{print $3}' | cut -d. -f1 | sed '/^$/d')";
	
	# sources.list pra Debian Squeeze
	squeeze="deb http://archive.debian.org/debian oldstable main contrib non-free
deb-src http://archive.debian.org/debian oldstable main contrib non-free

deb http://ftp.debian.org/debian/ squeeze-updates main contrib non-free
deb-src http://ftp.debian.org/debian/ squeeze-updates main contrib non-free

deb http://security.debian.org/ squeeze/updates main contrib non-free
deb-src http://security.debian.org/ squeeze/updates main contrib non-free";

	# sources.list para Debian Wheezy
	wheezy="deb http://ftp.br.debian.org/debian stable main contrib non-free
deb-src http://ftp.br.debian.org/debian stable main contrib non-free

deb http://ftp.debian.org/debian/ wheezy-updates main contrib non-free
deb-src http://ftp.debian.org/debian/ wheezy-updates main contrib non-free

deb http://security.debian.org/ wheezy/updates main contrib non-free
deb-src http://security.debian.org/ wheezy/updates main contrib non-free";

	# source list do Ubuntu 12.10
	ubuntu1210="";
	
	# sequencia de if, elif e else que determinará que sources.list será preenchido	
	if [ "$distro" = "Debian" ]; then
	
		if [ "$versao" = "6" ]; then
		
			echo "$squeeze" > /etc/apt/sources.list
			
		elif [ "$distro" = "7" ]; then
		
			echo "$wheezy" > /etc/apt/sources.list
			
		else
		
			# nao faça nada
			echo
			
		fi
		
	elif [ "$distro" = "Ubuntu" ]; then
	
		if [ "$versao" = "12" ]; then
			# iria criar o sources.list do Ubuntu 12.10 , mas não conheço muito do repo dele, logo deixará como está
			#[ "$(cat /etc/issue | awk '{print $3}' | cut -d. -f2 | sed '/^$/d')" = "10"] &&  echo "$ubuntu1210" > /etc/apt/sources.list || echo "";
			echo
			
		fi
		
	else
		# deixará como está
		echo
		
	fi
	
	# atualizando de novo, se houve novo source list, se não, continuará na mesma
	apt-get update
	apt-get upgrade
}

padroes(){

	# variável que pega o nome da distribuiçao, poderia ser tb: uname -a | awk '{print $2}', mas a sáida sera em minúsculo (debian)
	distro="$(cat /etc/issue | awk '{print $1}' | sed '/^$/d')";

	# se a distro for Debian, instalará os drives não-livres, se não, não instalará
	[ "$distro" = "Debian" ] && apt-get install firmware-linux-nonfree -y || echo "";
	
	# instalando Aplicativos para Usuários e Desenvolvedores
	apt-get install grub2 -y
	apt-get install apache2 -y
	apt-get install php5 -y
	apt-get install filezilla -y
	apt-get install gedit-plugins gedit-dev -y
	apt-get install flashplugin-nonfree -y
	apt-get install openjdk-7-jre -y
	apt-get install rar unrar p7zip p7zip-full p7zip-rar -y
	apt-get install k3b -y
	apt-get install virtualbox -y
}

# função para instalar os aplicativos personalizados
personalizados(){

	# pegando a URL para instalar os INSTALADORES amigos do pinguim
	instaladoresadp="http://aarnet.dl.sourceforge.net/project/instaladoresadp/instaladoresadp.tar.gz"
	
	# baixando os INSTALADORES
	wget $instaladoresadp
	
	# descomprimindo
	tar -zxf instaladoresadp.tar.gz
	
	# atribuino permissão de execução das mesmas
	chmod +x -R instaladoresadp
	
	# removendo o Iceweasel e instalando o Firefox, se não houver Iceweasel, não acontecerá nada (caso do Ubuntu e Debians-Like), só instalará o Firefox
	./rmiceinsfox.sh
	
	# dormindo por 2 segundos
	sleep 2
	
	# instalando o PHP-GTK
	./installPHPGTK.sh
	
	# dormindo por 2 segundos
	sleep 2
	
	# instalando o OpenSSH
	./installOpenSSH.sh
	
	# dormindo por 2 segundos
	sleep 2
	
	# instalando o NFS
	./installNFS.sh
	
	# dormindo por 2 segundos
	sleep 2
	./instfuncoesadp.sh
	
	# dormindo por 2 segundos
	sleep 2
	
	# verificar se é 32 ou 64 bits,pra baixar o pacote adequado do Aptana Studio 3 e Google Chrome
	if [ "$(getconf LONG_BIT)" = "64" ]; then

		aptanaurl="http://ufpr.dl.sourceforge.net/project/aptanadeb/Aptana_Studio_3_Setup_Linux_x86_64_3.4.2.deb"
		chromeurl="https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"
	
	elif [ "$(getconf LONG_BIT)" = "32" ]; then

		aptanaurl="http://ufpr.dl.sourceforge.net/project/aptanadeb/Aptana_Studio_3_Setup_Linux_x86_3.4.2.deb"
		chromeurl="https://dl.google.com/linux/direct/google-chrome-stable_current_i386.deb"

	fi
	
	# baixa o aptana adequado do Aptana Studio 3
	wget $aptanaurl
	
	# instala o pacote do Aptana Studio 3
	dpkg -i Aptana_Studio_3_Setup_Linux_x86_*.deb
	
	# baixa o pacote adequado do Google Chrome
	wget $chromeurl
	
	# instala o pacote adequado do Google Chrome
	dpkg -i google-chrome-stable_current*.deb
	
	# baixa o Skype
	if [ "$distro" = "Debian" ]; then
		
		# baixa e instala o Debian Multiarch(32 ou 64)
		wget http://download.skype.com/linux/skype-debian_4.2.0.11-1_i386.deb
		dpkg -i skype*.deb
		
	elif [ "$distro" = "Ubuntu" ]; then
	
		# baixa e instala o Ubuntu >= 12.04 Multiarch(32 ou 64)
		wget http://download.skype.com/linux/skype-ubuntu-precise_4.2.0.11-1_i386.deb
		dpkg -i skype*.deb
	fi
}

# função para instalar os aplicativos que dependerão de interação do usuário(para responder perguntas do Shell)
interativos(){
	
	# instala o MySQL Cliente e Servidor e mais o php5-mysql
	apt-get install mysql-client mysql-server php5-mysql -y
	
	# instala o PHPmyAdmin
	apt-get install phpmyadmin -y
}

# chama todas as funções
atualizar
novalista
padroes
personalizados
interativos

# se tudo der certo
echo "Full Script concluído com sucesso!"
echo "Pronto."
exit 0
