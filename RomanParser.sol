// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
//罗马转整数
contract RomanParser {
    function romanToInt(string memory s) public pure returns (uint) {
        bytes memory str = bytes(s);
        uint total = 0;
        uint prev = 0;

        for (uint i = str.length; i > 0; i--) {
            uint val = romanCharToInt(str[i - 1]);
            if (val < prev) {
                total -= val;
            } else {
                total += val;
            }
            prev = val;
        }

        return total;
    }

    function romanCharToInt(bytes1 ch) internal pure returns (uint) {
        if (ch == "I") return 1;
        if (ch == "V") return 5;
        if (ch == "X") return 10;
        if (ch == "L") return 50;
        if (ch == "C") return 100;
        if (ch == "D") return 500;
        if (ch == "M") return 1000;
        revert("Invalid Roman character");
    }
}