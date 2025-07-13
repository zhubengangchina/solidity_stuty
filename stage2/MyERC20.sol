// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
任务：参考 openzeppelin-contracts/contracts/token/ERC20/IERC20.sol实现一个简单的 ERC20 代币合约。要求：
合约包含以下标准 ERC20 功能：
balanceOf：查询账户余额。
transfer：转账。
approve 和 transferFrom：授权和代扣转账。
使用 event 记录转账和授权操作。
提供 mint 函数，允许合约所有者增发代币。
提示：
使用 mapping 存储账户余额和授权信息。
使用 event 定义 Transfer 和 Approval 事件。
部署到sepolia 测试网，导入到自己的钱包
*/

contract MyERC20 {

    string public name = "MyToken";
    string public symbol = "MTK";
    uint8 public decimals = 18;
    uint256 public totalSupply;
    address public owner;

    mapping (address => uint256) private balances;
    mapping (address => mapping(address => uint256)) private allowances;

    event Transfer(address indexed from,address indexed to,uint256 value);
    event Approval(address indexed owner,address indexed spender,uint256 value);

    modifier onlyOwner() {
        require (msg.sender == owner,"Not owner"); 
        _;
    }

    constructor() {
        owner = msg.sender;
    }


    function balanceof(address account) public view returns (uint256) {
        return balances[account];
    }

    function transfer(address to, uint256 amount) public returns(bool) {
        require(balances[msg.sender] >= amount,"Not balance");
        balances[msg.sender] -= amount;
        balances[to] += amount;
        emit Transfer(msg.sender, to, amount);
        return true; 
    }

    function approve(address spender,uint256 amount) public returns (bool) {
        allowances[msg.sender][spender] = amount;
        emit Approval (msg.sender, spender, amount);
        return true;
    }

    function allowance(address ownerAddr,address spender) public view returns (uint256) {
        return allowances[ownerAddr][spender];
    }

    function transferFrom(address from,address to,uint256 amount) public returns (bool) {
        uint allowed = allowances[from][msg.sender];
        require(allowed >= amount,"Allowance exceeded");
        require(balances[from] >=amount, "Insufficient balance");

        allowances[from][msg.sender] -= amount;
        balances[from] -= amount;
        balances[to] += amount; 

        emit Transfer(from, to,amount);
        return true;
    }

    function mint(address to,uint256 amount) public onlyOwner {
        balances[to] += amount;
        totalSupply = totalSupply + amount;
        emit Transfer(address(0), to,amount);
    }

}
