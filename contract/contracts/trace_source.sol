pragma solidity ^0.5;

contract Trace_Source {
	string[] Goods;					        	//此映射代表商品id和商品名称的映射
    uint goodcount;
    function initGoods() public {
        Goods = new string[](1);
        Goods[Goods.length - 1] = "AppleJam";
        Goods.length++;
        Goods[Goods.length - 1] = "beef";
        Goods.length++;
        Goods[Goods.length - 1] = "pork";
        Goods.length++;
        goodcount = 100;
    }

    function good() public view returns(string memory){
        string memory temp = "";
        for(uint i = 0; i < Goods.length; i++){
            temp = strConcat(temp, Goods[i]);
            temp = strConcat(temp, " ");
            temp = strConcat(temp, uint2str(i));
            temp = strConcat(temp, " ");
        }
        return temp;
    }

    address[] addr;										//代表当前全部节点的地址 从而实现地址节点的一一对应
    function initaddr() public{
        addr = new address[](1);
    }
    
    function addrindex() public view returns(uint){
        return addr.length;
    }

    function addrvalue(uint id) public view returns(address ){
        return addr[id];
    }

    mapping(string => string) GoodFind;                 //生产出的商品 => 原料
    mapping(string => string[]) FindGood;               //原料 => 生产出的商品
    mapping(string => uint) BlockNumber;                //GoodFind 与 BlockNumber 一一对应 一遍溯源

    function goodcheck(string memory _string)public view returns(string memory) {
        return GoodFind[_string];
    }

    function checkgood(string memory _string, uint _id)public view returns(string memory) {
        return FindGood[_string][_id];
    }

	struct Good{
    	//uint id;										//代表该商品的大类
    	mapping(string => uint) GoodAmount;				//商品类中每批货的数量
    }

    struct Trans{
    	mapping(string => uint) tran;					//name => time
    }

    struct Node{
		uint role;										//角色设置 农场主 工厂 仓库 市场 消费者
		address location;								//保证一个地址只能有一个Node
        string place;         							//当前代表角色地理位置信息
        mapping(address => Trans) child;    			//连接当前节点的子节点 即向子节点供货 (子节点地址 => 货号)格式方便溯源
        mapping(uint => Good) good;						//当前节点的所有货物记录 按照 货类{货号 => 数量} 来定义
        mapping(uint => string) goodkind;               //每个node生产的商品名称
        mapping(string => uint) producted;              //每个node生产的记录 产品名 => 时间

    }

    mapping(address => Node) Nodes;                     //记录所有用户

    function initmarket(address _address, string memory _place) public returns (uint){
        for(uint i = 0; i < addr.length; i++){
            if(addr[i] == _address){
                return 0;
            }
        }
        Nodes[_address].role = 5;
        Nodes[_address].location = _address;
        Nodes[_address].place = _place;
        addr[addr.length - 1] = _address;
        addr.length++;
        return 1;
    }

    function showtran(address _address, address _to, string memory _goodname) public view returns (uint){
        return Nodes[_address].child[_to].tran[_goodname];
    }

    function showamount(address _address, uint _goodindex, string memory _goodname) public view returns (uint){
        return Nodes[_address].good[_goodindex].GoodAmount[_goodname];
    }

    function initgoodkind1(address _address) public{
        Nodes[_address].goodkind[0] = "seed";
    }

    function initgoodkind2(address _address)public{
        Nodes[_address].goodkind[0] = "apple";
    }

    function initgoodkind3(address _address)public{
        Nodes[_address].goodkind[0] = "applemash";
    }

    function initgoodkind4(address _address)public{
        Nodes[_address].goodkind[0] = "applejam";
    }

    function NewNode(uint _role, address _address, string memory _place) public returns (uint){
        if(_role < 0){
            return 0;
        }
        for(uint i = 0; i < addr.length; i++){
            if(addr[i] == _address){
                return 0;
            }
        }
        Nodes[_address].role = _role;
        Nodes[_address].location = _address;
        Nodes[_address].place = _place;
    	addr[addr.length - 1] = _address;
        addr.length++;
        return 1;
    }

    function name(string memory _GoodIndex) internal returns(string memory){
        goodcount++;
        return strConcat(_GoodIndex, uint2str(goodcount));
    }

    function transport(address _from, address _to, uint _GoodIndex, string memory _GoodName, uint _account ,uint _GoodKind) public returns (string memory){
    	if(Nodes[_from].location == Nodes[_to].location)
    		return "you cant transport to yourself";
    	if(_account == 0)
    		return "you cant transport nothing";
    	if(Nodes[_from].role <= Nodes[_to].role){
    		if(Nodes[_from].good[_GoodIndex].GoodAmount[_GoodName] != 0){
    			if(Nodes[_from].good[_GoodIndex].GoodAmount[_GoodName] > _account){
    				Nodes[_from].good[_GoodIndex].GoodAmount[_GoodName] -= _account;
                    string memory _name = name(Nodes[_from].goodkind[_GoodKind]);
   					Nodes[_to].good[_GoodIndex].GoodAmount[_name] = _account;
                    GoodFind[_name] = _GoodName;
                    BlockNumber[_name] = block.number;
                    FindGood[_GoodName].push(_name);
   				  	Nodes[_from].child[Nodes[_to].location].tran[_GoodName] = now;
   					return "transport success";
    			}
    			else 
    				return "short of account";
    		}
    		else 
    			return "you dont have this good";
    	}
    	else 
    		return "wrong role to transport";
    }

/*
    function AddAmount(address _node, uint _GoodIndex, uint _account) public returns (string memory){
    	string memory name = name(Nodes[_node].goodkind[_GoodIndex]);
    	if(Nodes[_node].good[_GoodIndex].GoodAmount[name] > 0){
    		Nodes[_node].good[_GoodIndex].GoodAmount[name] += _account;
    	}
    	else 
    		Nodes[_node].good[_GoodIndex].GoodAmount[name] = _account;
        return name;
    }
*/

    function product(address _address, uint _GoodIndex, string memory _GoodName, uint _product, uint _good, uint _GoodId) public returns (uint){
        //生产函数 将自身的原料转化为下一级商品
        if(Nodes[_address].good[_GoodIndex].GoodAmount[_GoodName] < _product){
            return 0;
        }
        Nodes[_address].good[_GoodIndex].GoodAmount[_GoodName] -= _product;
        string memory name = name(Nodes[_address].goodkind[_GoodId]);
        Nodes[_address].good[_GoodIndex].GoodAmount[name] += _good;
        GoodFind[name] = _GoodName;
        BlockNumber[name] = block.number;
        FindGood[_GoodName].push(name);
        Nodes[_address].producted[name] = now;
        return 1;
    }

    function compareStrings (string memory a, string memory b) internal view returns (bool) {
         return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }

    function toString(address x) internal view returns (string memory) {
        bytes memory b = new bytes(20);
        for (uint i = 0; i < 20; i++)
            b[i] = byte(uint8(uint(x) / (2**(8*(19 - i)))));
        return string(b);
    }

    function trace_source(string memory _GoodName, uint _GoodId) public view returns (string memory){
        string[] memory path = new string[](10);
        address[] memory result = new address[](10);
        string memory check = _GoodName;
        path[0] = _GoodName;
        uint count = 1;
        while(!compareStrings(goodcheck(check), "")){
            check = goodcheck(check);
            path[count] = check;
            count++;
        }
        uint index = 0;
        while(!compareStrings(path[index], "")){
            index++;
        }
        uint c = 0;
        index --;
        for(uint j = 0; j <= index; j++){
            for(uint i = 0; i < addr.length; i++){
                //找所有符合_GoodName最上层的节点
                 if(Nodes[addr[i]].good[_GoodId].GoodAmount[path[index - j]] > 0){
                    result[c] = addr[i];
                    c++;
                }
            }
        }
        count = 0;
        string memory temp = "";
        while(result[count] != address(0)){
            string memory status;
            if(result[count] == result[count + 1]){
                //先生产再运输
                status = strConcat(" 生产 ", uint2str(Nodes[result[count]].producted[path[index - count - 1]]));
                temp = strConcat(temp, Nodes[result[count]].place);
                temp = strConcat(temp, status);
                temp = strConcat(temp, " ");
                temp = strConcat(temp, path[index - count]);
                temp = strConcat(temp, " ");
                temp = strConcat(temp, uint2str(BlockNumber[path[index - count]]));
                temp = strConcat(temp, " ");
                if(result[count + 2] == address(0)){
                    temp = strConcat(temp, Nodes[result[count + 1]].place);
                    return temp;
                }
                status = strConcat(" 运输 ", uint2str(Nodes[result[count]].child[result[count + 2]].tran[path[index - count - 1]]));
                temp = strConcat(temp, Nodes[result[count]].place);
                temp = strConcat(temp, status);
                temp = strConcat(temp, " ");
                temp = strConcat(temp, path[index - count - 1]);
                temp = strConcat(temp, " ");
                temp = strConcat(temp, uint2str(BlockNumber[path[index - count]] + 1));
                temp = strConcat(temp, " ");
                count += 2;
            }
            else{
                //仅生产或者运输
                if(result[count + 1] == address(0)){
                    temp = strConcat(temp, Nodes[result[count]].place);
                    temp = strConcat(temp, " ");
                    temp = strConcat(temp, path[index - count]);
                    temp = strConcat(temp, " ");
                    temp = strConcat(temp, uint2str(BlockNumber[path[index - count]]));
                    temp = strConcat(temp, " ");
                    return temp;
                }
                if(Nodes[result[count]].producted[path[index - count]] > 0){
                    status = strConcat(" 生产 ", uint2str(Nodes[result[count]].producted[path[index - count]]));
                }
                else{
                    status = strConcat(" 运输 ", uint2str(Nodes[result[count]].child[result[count + 1]].tran[path[index - count]]));
                }
                temp = strConcat(temp, Nodes[result[count]].place);
                temp = strConcat(temp, status);
                temp = strConcat(temp, " ");
                temp = strConcat(temp, path[index - count]);
                temp = strConcat(temp, " ");
                temp = strConcat(temp, uint2str(BlockNumber[path[index - count]]));
                temp = strConcat(temp, " ");
                count++;
            }
        }
        return temp;
    }

    function strConcat(string memory _a, string memory _b) internal pure returns (string memory){
        bytes memory _ba = bytes(_a);
        bytes memory _bb = bytes(_b);
        string memory ret = new string(_ba.length + _bb.length);
        bytes memory bret = bytes(ret);
        uint k = 0;
        for (uint i = 0; i < _ba.length; i++)
            bret[k++] = _ba[i];
        for (uint i = 0; i < _bb.length; i++) 
            bret[k++] = _bb[i];
        return string(ret);
   }  

    function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len - 1;
        while (_i != 0) {
            bstr[k--] = byte(uint8(48 + _i % 10));
            _i /= 10;
        }
        return string(bstr);
    }

    function source(string memory _GoodName) public view returns (string memory){
        string[] memory s = new string[](10);
        s[0] = _GoodName;
        uint i = 0;
        uint count = 0;
        uint index = 1;
        while(FindGood[s[count]].length != 0){
            i = 0;
            for(uint j = 0; j < FindGood[s[count]].length; j++){
                s[index] = FindGood[s[count]][i];
                index++;
                i++;
            }
            count++;
        }
        string memory result = "";
        i = 0;
        while(!compareStrings(s[i], "")){
            result = strConcat(result, s[i]);
            result = strConcat(result, " ");
            i++;
        }
        return result;
    }

    function splitSignature(bytes memory sig) public pure returns(uint8 v, bytes32 r, bytes32 s){
        require(sig.length == 65);
        assembly {
            // first 32 bytes, after the length prefix.
            r := mload(add(sig, 32))
            // second 32 bytes.
            s := mload(add(sig, 64))
            // final byte (first byte of the next 32 bytes).
            v := byte(0, mload(add(sig, 96)))
        }

        return (v+27, r, s);
    }

    function recoverSigner(bytes32 message, bytes memory sig) public pure returns (address){
        (uint8 v, bytes32 r, bytes32 s) = splitSignature(sig);
        return ecrecover(message, v, r, s);
    }


    function tiaoshi(address _address1, address _address2, address _address3, address _address4, address _address5) public{
        initGoods();
        initaddr();
        NewNode(1, _address1, "北京市-顺鑫石门农产品批发市场公司");
        initgoodkind1(_address1);
        product(_address1, 0, "", 0, 100, 0);
   //   AddAmount(_address1, 0, 100);
        NewNode(2, _address2, "北京市-昌平区燕南苹果种植园");
        initgoodkind2(_address2);
        NewNode(3, _address3, "北京市-北京天周食品加工有限公司");
        initgoodkind3(_address3);
        NewNode(4, _address4, "北京市-北京仙果源罐头食品有限公司");
        initgoodkind4(_address4);
        NewNode(5, _address5, "北京市-京客隆超市(双龙店)");
        initgoodkind4(_address5);

        transport(_address1, _address2, 0, "seed101", 80, 0);
        product(_address2, 0, "seed102", 60, 30, 0);
        transport(_address2, _address3, 0, "apple103", 20, 0);
        product(_address3, 0, "apple104", 10, 30, 0);
        transport(_address3, _address4, 0, "applemash105", 20, 0);
        product(_address4, 0, "applemash106", 15, 30, 0);
        transport(_address4, _address5, 0, "applejam107", 29, 0);
    }


    function decode() public returns (address){
        bytes memory signedString =hex"f4128988cbe7df8315440adde412a8955f7f5ff9a5468a791433727f82717a6753bd71882079522207060b681fbd3f5623ee7ed66e33fc8e581f442acbcf6ab800";
        bytes32  r = bytesToBytes32(slice(signedString, 0, 32));
        bytes32  s = bytesToBytes32(slice(signedString, 32, 32));
        byte  v = slice(signedString, 64, 1)[0];
        return ecrecoverDecode(r, s, v);
  }

    function slice(bytes memory data, uint start, uint len) public returns (bytes memory){
        bytes memory b = new bytes(len);
        for(uint i = 0; i < len; i++){
            b[i] = data[i + start];
        }
    return b;
  }

    function ecrecoverDecode(bytes32 r, bytes32 s, byte v1) public returns (address addr){
        uint8 v = uint8(v1) + 27;
        addr = ecrecover(hex"4e03657aea45a94fc7d47ba826c8d667c0d1e6e33a64a036ec44f58fa12d6c45", v, r, s);
  }
    
    function bytesToBytes32(bytes memory source) public returns (bytes32 result) {
        assembly {
        result := mload(add(source, 32))
    }
  }
}