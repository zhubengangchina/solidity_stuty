// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

//给两个升序排序的 uint[] 类型数组 A 和 B

//返回一个新的升序数组，包含 A 和 B 所有元素
contract ArrayMerger {

    function merge(uint[] memory a, uint[] memory b) public pure returns (uint[] memory){
        uint lenA = a.length;
        uint lenB = b.length;
        uint[] memory result = new uint[](lenA + lenB);

        uint i = 0;
        uint j = 0;
        uint k = 0;
        while (i <lenA && j < lenB ){
            if(a[i] <= b[j]) {
                result[k++] = a[i++];
            } else {
                result[k++] = b[j++];
            }
        }

        while (i < lenA){
            result[k++] = a[i++];
        }
        while (j < lenB) {
            result[k++] = b[j++];
        }
        return result;
    }
}