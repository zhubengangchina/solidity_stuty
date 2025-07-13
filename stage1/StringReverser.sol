// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract StringReverser {

    //反转一个字符串。输入 "abcde"，输出 "edcba"
    function reverse(string memory str) public pure returns (string memory) {
        bytes memory strBytes = bytes(str);
        uint len = strBytes.length;
        for (uint i = 0; i < len / 2; i++) {
            // 交换 i 与 len-1-i 的字节
            bytes1 temp = strBytes[i];
            strBytes[i] = strBytes[len - 1 - i];
            strBytes[len - 1 - i] = temp;
        }

        return  string(strBytes);
    }
}