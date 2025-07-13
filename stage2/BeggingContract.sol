/*
编写一个讨饭合约
任务目标
使用 Solidity 编写一个合约，允许用户向合约地址发送以太币。
记录每个捐赠者的地址和捐赠金额。
允许合约所有者提取所有捐赠的资金。

任务步骤
编写合约
创建一个名为 BeggingContract 的合约。
合约应包含以下功能：
一个 mapping 来记录每个捐赠者的捐赠金额。
一个 donate 函数，允许用户向合约发送以太币，并记录捐赠信息。
一个 withdraw 函数，允许合约所有者提取所有资金。
一个 getDonation 函数，允许查询某个地址的捐赠金额。
使用 payable 修饰符和 address.transfer 实现支付和提款。
部署合约
在 Remix IDE 中编译合约。
部署合约到 Goerli 或 Sepolia 测试网。
测试合约
使用 MetaMask 向合约发送以太币，测试 donate 功能。
调用 withdraw 函数，测试合约所有者是否可以提取资金。
调用 getDonation 函数，查询某个地址的捐赠金额。

任务要求
合约代码：
使用 mapping 记录捐赠者的地址和金额。
使用 payable 修饰符实现 donate 和 withdraw 函数。
使用 onlyOwner 修饰符限制 withdraw 函数只能由合约所有者调用。
测试网部署：
合约必须部署到 Goerli 或 Sepolia 测试网。
功能测试：
确保 donate、withdraw 和 getDonation 函数正常工作。
提交内容
合约代码：提交 Solidity 合约文件（如 BeggingContract.sol）。
合约地址：提交部署到测试网的合约地址。
测试截图：提交在 Remix 或 Etherscan 上测试合约的截图。
*/


/*
| 功能                     | 描述                     |
| ---------------------- | ---------------------- |
| `donate()`             | 允许用户发送 ETH 到合约，并记录捐赠金额 |
| `withdraw()`           | 只有合约拥有者可以提取合约内全部 ETH   |
| `getDonation(address)` | 查询某个地址捐赠了多少 ETH        |

*/
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BeggingContract {

    //合约所有者
    address public owner;
    // 记录每个捐赠者的捐赠金额
    mapping(address => uint256) public donations;

    // 总捐赠金额
    uint256 public totalDonations;

    //捐赠时间限制
    uint256 public doantionStartTime;
    uint256 public donationEndTime;

    //捐赠排行榜
    struct Donor {
        address donorAddress;
        uint256 amount;
    }

    Donor[] public topDonors;

    uint256 public constant TOP_DONORS_COUNT = 3;

    //事件：记录捐赠
    event Donated(address indexed donor,uint256 amount);

    //事件：记录提款
    event Withdraw(address indexed owner,uint256 amount);

    event DonationPeriodSet(uint256 start,uint256 end);

    constructor(uint256 _donationStartTime,uint256 _donationEndTime) {
        setDonationPeriod(_donationStartTime, _donationEndTime);
        owner = msg.sender;

        //初始化排行榜
        for(uint i = 0 ;i < TOP_DONORS_COUNT;++i){
             topDonors.push(Donor(address(0),0));
        }
    }
    
    //允许任何人捐赠ETH
    function donate() public payable onlyDuringDonationPeriod{ 
        require(msg.value > 0,"Donation must be greater than zero");
        donations[msg.sender] += msg.value;
        totalDonations += msg.value;

        //更新排行榜
        updateTopDonors(msg.sender,donations[msg.sender]);

        emit Donated(msg.sender,msg.value);
    }

    //只有合约拥有者才能提取合约内全部Eth
    modifier onlyOwner() {
         require(owner == msg.sender,"Only owner can withdraw");
         _;
    }

    modifier onlyDuringDonationPeriod() {
        require(block.timestamp >= doantionStartTime, "Donation period has not started");
        require(block.timestamp <= donationEndTime, "Donation period has ended");
        _;
    }

    function updateTopDonors(address _donor,uint256 amount) private  {
        //检查是否在排行榜中
        int256 existingIndex = -1;
        for (uint256 i = 0; i < topDonors.length;i++) {
            if (topDonors[i].donorAddress == _donor) {
                existingIndex =int256(i);
                break; 
            }
        }

        if (existingIndex >= 0) {
            topDonors[uint256(existingIndex)].amount += amount;
        } else {
            //如果不在排行榜中检查是否能进入
            uint256 minIndex = 0;
            for (uint256 i = 1; i < topDonors.length; i++) {
                if (topDonors[i].amount < topDonors[minIndex].amount) {
                    minIndex = i;
                }
            }


            // 如果当前用户总捐赠额比最小值还大，替换
            if (amount > topDonors[minIndex].amount) {
                topDonors[minIndex] = Donor(_donor, amount);
            }
        }

        // 重新排序排行榜
        sortTopDonors();
    }

    // 对排行榜进行排序（从高到低）
    function sortTopDonors() private {
        for (uint256 i = 1; i < topDonors.length; i++) {
            for (uint256 j = 0; j < i; j++) {
                if (topDonors[i].amount > topDonors[j].amount) {
                    Donor memory temp = topDonors[i];
                    topDonors[i] = topDonors[j];
                    topDonors[j] = temp;
                }
            }
        }
    }

    function setDonationPeriod(uint256 _start,uint _end) public onlyOwner {
        require(_start < _end,"Start time must be before end time");
        doantionStartTime = _start;
        donationEndTime = _end;
        emit DonationPeriodSet(_start,_end);
    }

    //提款
    function withdraw() public onlyOwner{
        uint256 balance = address(this).balance;
        require(balance > 0,"No funds to withdraw");
        payable (owner).transfer(address(this).balance);
        emit Withdraw(owner, balance);
    }

    // 获取前3名捐赠者
    function getTopDonors() public view returns (Donor[3] memory) {
        Donor[3] memory result;
        for (uint256 i = 0; i < topDonors.length && i < 3; i++) {
            result[i] = topDonors[i];
        }
        return result;
    }

    //查询某个地址捐赠了多少Eth
    function getDonation(address _addr) public view returns (uint256){
        return donations[_addr];
    }

    //fallback: 防止误调用合约
    fallback() external payable {
        donate();
    }

    receive() external payable{ 
        donate();
    }

    // 获取合约当前余额
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}