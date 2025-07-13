//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
作业2：在测试网上发行一个图文并茂的 NFT
任务目标
使用 Solidity 编写一个符合 ERC721 标准的 NFT 合约。
将图文数据上传到 IPFS，生成元数据链接。
将合约部署到以太坊测试网（如 Goerli 或 Sepolia）。
铸造 NFT 并在测试网环境中查看。
任务步骤
编写 NFT 合约
使用 OpenZeppelin 的 ERC721 库编写一个 NFT 合约。
合约应包含以下功能：
构造函数：设置 NFT 的名称和符号。
mintNFT 函数：允许用户铸造 NFT，并关联元数据链接（tokenURI）。
在 Remix IDE 中编译合约。
准备图文数据
准备一张图片，并将其上传到 IPFS（可以使用 Pinata 或其他工具）。
创建一个 JSON 文件，描述 NFT 的属性（如名称、描述、图片链接等）。
将 JSON 文件上传到 IPFS，获取元数据链接。
JSON文件参考 https://docs.opensea.io/docs/metadata-standards
部署合约到测试网
在 Remix IDE 中连接 MetaMask，并确保 MetaMask 连接到 Goerli 或 Sepolia 测试网。
部署 NFT 合约到测试网，并记录合约地址。
铸造 NFT
使用 mintNFT 函数铸造 NFT：
在 recipient 字段中输入你的钱包地址。
在 tokenURI 字段中输入元数据的 IPFS 链接。
在 MetaMask 中确认交易。
查看 NFT
打开 OpenSea 测试网 或 Etherscan 测试网。
连接你的钱包，查看你铸造的 NFT。
*/

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";


contract MyNFT is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    constructor() ERC721("MyAwesomeNFT", "MAN") {}

    function mintNFT(address recipient, string memory tokenURI) public returns (uint256) {
        uint256 newTokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(recipient, newTokenId);
        _setTokenURI(newTokenId, tokenURI);
        return newTokenId;
    }
}

/*
第二步：上传图片和元数据到 IPFS
1. 准备图片（例如一张 PNG）
你可以用 https://pinata.cloud 或 https://nft.storage 上传。

2. 创建元数据 JSON 文件（符合 OpenSea 标准）
json
复制
编辑
{
  "name": "Solidity NFT #1",
  "description": "This is a test NFT minted from Remix!",
  "image": "ipfs://QmXx...xxx/image.png"
}
上传该 JSON 文件到 IPFS，获得一个 tokenURI，格式如下：

arduino
复制
编辑
ipfs://QmAbcd12345xyz/metadata.json
建议使用 HTTP 网关（供 Remix 测试用）：
https://gateway.pinata.cloud/ipfs/QmAbcd12345xyz/metadata.json

✅ 第三步：使用 Remix 部署合约
操作步骤：
打开 Remix IDE

安装 OpenZeppelin 合约：

在 File Explorer 面板中，点击 "+" 添加 MyNFT.sol

添加 openzeppelin：

bash
复制
编辑
https://github.com/OpenZeppelin/openzeppelin-contracts.git
编译合约，选择 0.8.20

在 Deploy & Run 页面：

环境：Injected Provider - MetaMask

选择你的钱包连接到 Sepolia 网络

点击部署

✅ 第四步：mint NFT
部署成功后，展开合约，点击：

solidity
复制
编辑
mintNFT("你的地址", "https://gateway.pinata.cloud/ipfs/xxx/metadata.json")
MetaMask 会弹出交易确认，签名后你将铸造一枚 NFT。

✅ 第五步：查看 NFT 效果
OpenSea 测试网地址：
https://testnets.opensea.io

连接你的钱包，点击 Profile → 查看你拥有的 NFT

如果 NFT 没显示，可等几分钟缓存或点击 OpenSea 的 “Refresh Metadata”
*/