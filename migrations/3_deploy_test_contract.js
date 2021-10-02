var Namelessfolks=artifacts.require ("./Namelessfolks.sol");
module.exports = function(deployer) {
      // deployer.deploy(Namelessverse,"Nameless Folks",
      //                               "FOLK",
      //                               "0xf57b2c51ded3a29e6891aba85459d600256cf317");
      deployer.deploy(Namelessfolks,
        "https://gateway.pinata.cloud/ipfs/QmSPm7pWcL9GXwqWkc53r3gL6tj98UoUwVVMv9sLK5vmx4");
}
