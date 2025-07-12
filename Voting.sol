// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
*| 功能       | 说明                                    |
| -------- | ------------------------------------- |
| ✅ 候选人得票数 | `mapping(string => uint)` 保存候选人名和得票数  |
| ✅ 投票功能   | `vote(string calldata name)` 投票给某个候选人 |
| ✅ 查询票数   | `getVotes(string memory name)` 返回票数   |
| ✅ 重置     | `resetVotes()` 将所有候选人得票数归零，仅限管理员调用    |

*/
contract Voting {

    address public owner;
    mapping (string => uint) private votes;
    string[] private candidates;

    constructor(){
        owner = msg.sender;
    } 

    modifier onlyOwner{
        require(msg.sender == owner, "only owner");
         _;
    }

     // 给某个候选人投票（如果是第一次投票，该候选人会被记录）
     function vote(string calldata name) public{
        if (votes[name] == 0) {
            candidates.push(name);
        }
        votes[name] +=1;
     }

      // 获取某个候选人的得票数
      function getVotes(string memory name) public view returns (uint) {
        return votes[name];
      }

      // 重置所有候选人的得票数（仅限 owner）

      function resetVotes() public onlyOwner {
        for (uint i = 0; i < candidates.length;i++) {
            votes[candidates[i]]=0;
        }
      }
    


}