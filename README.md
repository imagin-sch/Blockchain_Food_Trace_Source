# Blockchain_Food_Trace_Source
一个基于truffle编译器和ganache区块链网络的智能合约系统 主要功能是实现食品溯源

辣鸡代码 随便开源(╯‵□′)╯︵┻━┻
Author:Imagin

Usage:
  
  1.安装Ganache Truffle 环境
    我的本地环境：  
        Ganache-2.0.1
        Truffle v5.0.11 (core: 5.0.11)
        Node v10.15.3
        
  2.配置Ganache
    将端口号设置为7545，网络号设置为5777，与根目录下的配置文件truffle-config.js内容相同即可
    
	
  3.启动truffle
    使用cmd命令行进入到contract文件夹内，输入truffle migrate --reset，合约即可部署到区块链网络上。
  
  
  4.前端文件
    记录部署的合约地址，将前端四个文件的相应地址更改，否则将无法使用本系统。
	  /contract/trace_source.html的60行， /contract/source.html的49行， /contract/showkind.html的47行以及 /contract/query.html的第100行。
    （不要骂我，随缘写的代码嘿嘿嘿）
  
  
  5.启动
    合约里专门准备了一个初始化函数tiaoshi()，可以首先调用，向区块链里写数据，便于进行查询
    
