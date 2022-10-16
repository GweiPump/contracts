const { expect } = require("chai");
// const { ethers } = require("hardhat");
const { ethers, waffle} = require("hardhat");
const provider = waffle.provider;

describe("mockGweiPump Tests:", function () {

      let erc20LINK;
      let deployedErc20LINK;
      let mockGweiPump;
      let deployedMockGweiPump;
      let owner;
      let addr1;
      let addr2;
      let addrs;

      beforeEach(async function () {

        erc20LINK = await ethers.getContractFactory("LINK");
        [owner, addr1, addr2, ...addrs] = await ethers.getSigners();
        deployedErc20LINK = await erc20LINK.deploy();

        mockGweiPump = await ethers.getContractFactory("mockGweiPump");
        [owner, addr1, addr2, ...addrs] = await ethers.getSigners();
        deployedMockGweiPump = await mockGweiPump.deploy(deployedErc20LINK.address);

      });

      describe("constructor()", function () {
          it("isPumpFilled == 1", async function () {
            expect(await deployedMockGweiPump.isPumpFilled()).to.equal("1");
          });
          it("lastWtiPriceCheckUnixTime == 0", async function () {
            expect(await deployedMockGweiPump.lastWtiPriceCheckUnixTime()).to.equal("0");
          });
          it("WtiPriceOracle == 0", async function () {
            expect(await deployedMockGweiPump.WtiPriceOracle()).to.equal("0");
          });
          it("Owner == msg.sender at deployment", async function () {
            expect(await deployedMockGweiPump.Owner()).to.equal(owner.address);
          });
       });

       describe("mockChainlinkNodeRequestWtiPrice(mockOracleValue)", function () {
          it("Set 8476500000 and update WtiPriceOracle to 8476500000, then try to set 0 and stay 8476500000", async function () {
            const transactionCallAPI = await deployedMockGweiPump.mockChainlinkNodeRequestWtiPrice("8476500000");
            const tx_receiptCallAPI = await transactionCallAPI.wait();
            expect(await deployedMockGweiPump.WtiPriceOracle()).to.equal("8476500000");

            const transactionCallAPI2 = await deployedMockGweiPump.mockChainlinkNodeRequestWtiPrice("0");
            const tx_receiptCallAPI2 = await transactionCallAPI2.wait();
            expect(await deployedMockGweiPump.WtiPriceOracle()).to.equal("8476500000");
          });

        });

        describe("ownerPumpFilledStatus(status)", function () {
          it("Revert if msg.sender != Owner", async function () {
            await expect(
              deployedMockGweiPump.connect(addr1).ownerPumpFilledStatus("0")
            ).to.be.revertedWith("notOwner()");
          });
           it("Update isPumpFilled to be 0 and then 1.", async function () {
             const transactionCallAPI = await deployedMockGweiPump.ownerPumpFilledStatus("0");
             const tx_receiptCallAPI = await transactionCallAPI.wait();
             expect(await deployedMockGweiPump.isPumpFilled()).to.equal("0");

             const transactionCallAPI2 = await deployedMockGweiPump.ownerPumpFilledStatus("1");
             const tx_receiptCallAPI2 = await transactionCallAPI2.wait();
             expect(await deployedMockGweiPump.isPumpFilled()).to.equal("1");
           });

         });

         describe("mockBuyOil40Milliliters(status)", function () {
           it("Revert if msg.sender != Owner", async function () {
             await expect(
               deployedMockGweiPump.mockBuyOil40Milliliters()
             ).to.be.revertedWith("oraclePriceFeedZero()");
           });
           it("Revert if msg.value < mockWti40Milliliters()", async function () {
             const transactionCallAPI = await deployedMockGweiPump.mockChainlinkNodeRequestWtiPrice("8476500000");
             const tx_receiptCallAPI = await transactionCallAPI.wait();
             expect(await deployedMockGweiPump.WtiPriceOracle()).to.equal("8476500000");
             expect(await deployedMockGweiPump.mockWti40Milliliters()).to.equal("26708488188717925");

             await expect(
               deployedMockGweiPump.mockBuyOil40Milliliters({value: "26708488188717924"})
             ).to.be.revertedWith("msgValueTooSmall()");
           });

           it("Buy if msg.value == mockWti40Milliliters()", async function () {
             const transactionCallAPI = await deployedMockGweiPump.mockChainlinkNodeRequestWtiPrice("8476500000");
             const tx_receiptCallAPI = await transactionCallAPI.wait();
             expect(await deployedMockGweiPump.WtiPriceOracle()).to.equal("8476500000");
             expect(await deployedMockGweiPump.mockWti40Milliliters()).to.equal("26708488188717925");

             const transactionCallAPI2 = await deployedMockGweiPump.mockBuyOil40Milliliters({value:"26708488188717925"});
             const tx_receiptCallAPI2 = await transactionCallAPI2.wait();
             expect(await deployedMockGweiPump.isPumpFilled()).to.equal("0");

           });
           it("Buy and refund extra amount msg.value > mockWti40Milliliters()", async function () {
             const transactionCallAPI = await deployedMockGweiPump.mockChainlinkNodeRequestWtiPrice("8476500000");
             const tx_receiptCallAPI = await transactionCallAPI.wait();
             expect(await deployedMockGweiPump.WtiPriceOracle()).to.equal("8476500000");
             expect(await deployedMockGweiPump.mockWti40Milliliters()).to.equal("26708488188717925");

             const transactionCallAPI2 = await deployedMockGweiPump.mockBuyOil40Milliliters({value:"26708488188717926"});
             const tx_receiptCallAPI2 = await transactionCallAPI2.wait();
             expect(await deployedMockGweiPump.isPumpFilled()).to.equal("0");

           });
           it("Revert if Owner did not refill pump after bought from user", async function () {
             const transactionCallAPI = await deployedMockGweiPump.mockChainlinkNodeRequestWtiPrice("8476500000");
             const tx_receiptCallAPI = await transactionCallAPI.wait();
             expect(await deployedMockGweiPump.WtiPriceOracle()).to.equal("8476500000");
             expect(await deployedMockGweiPump.mockWti40Milliliters()).to.equal("26708488188717925");

             const transactionCallAPI2 = await deployedMockGweiPump.mockBuyOil40Milliliters({value:"26708488188717925"});
             const tx_receiptCallAPI2 = await transactionCallAPI2.wait();
             expect(await deployedMockGweiPump.isPumpFilled()).to.equal("0");

             await expect(
               deployedMockGweiPump.mockBuyOil40Milliliters({value: "26708488188717925"})
             ).to.be.revertedWith("pumpNotFilled()");
           });
          });

          describe("manualUpKeep(status)", function () {
            it("Revert if contract has less than 0.01 LINK", async function () {
              await expect(
                deployedMockGweiPump.manualUpKeep("8476500000")
              ).to.be.revertedWith("upKeepNotNeeded()");
            });
            it("upKeep once contract has 0.01 LINK at least", async function () {
              const transactionCallAPI = await deployedErc20LINK.transfer(deployedMockGweiPump.address,"10000000000000000");
              const tx_receiptCallAPI = await transactionCallAPI.wait();
              expect(await deployedErc20LINK.balanceOf(deployedMockGweiPump.address)).to.equal("10000000000000000");

              const transactionCallAPI2 = await deployedMockGweiPump.manualUpKeep("8476500000")
              const tx_receiptCallAPI2 = await transactionCallAPI2.wait();
              expect(await deployedMockGweiPump.WtiPriceOracle()).to.equal("8476500000");
              expect(await deployedMockGweiPump.mockWti40Milliliters()).to.equal("26708488188717925");

            });
            it("Revert if not enough time has passed after an upKeep", async function () {
              const transactionCallAPI = await deployedErc20LINK.transfer(deployedMockGweiPump.address,"20000000000000000");
              const tx_receiptCallAPI = await transactionCallAPI.wait();
              expect(await deployedErc20LINK.balanceOf(deployedMockGweiPump.address)).to.equal("20000000000000000");

              const transactionCallAPI2 = await deployedMockGweiPump.manualUpKeep("8476500000")
              const tx_receiptCallAPI2 = await transactionCallAPI2.wait();
              expect(await deployedMockGweiPump.WtiPriceOracle()).to.equal("8476500000");
              expect(await deployedMockGweiPump.mockWti40Milliliters()).to.equal("26708488188717925");

              await network.provider.send("evm_increaseTime", [86385]) //1 block away from 1 day in seconds.
              await network.provider.send("evm_mine") // Increase time.

              await expect(
                deployedMockGweiPump.manualUpKeep("8476500000")
              ).to.be.revertedWith("upKeepNotNeeded()");
            });
            it("upKeep after enough time has passed from last upKeep", async function () {
              const transactionCallAPI = await deployedErc20LINK.transfer(deployedMockGweiPump.address,"20000000000000000");
              const tx_receiptCallAPI = await transactionCallAPI.wait();
              expect(await deployedErc20LINK.balanceOf(deployedMockGweiPump.address)).to.equal("20000000000000000");

              const transactionCallAPI2 = await deployedMockGweiPump.manualUpKeep("8476500000")
              const tx_receiptCallAPI2 = await transactionCallAPI2.wait();
              expect(await deployedMockGweiPump.WtiPriceOracle()).to.equal("8476500000");
              expect(await deployedMockGweiPump.mockWti40Milliliters()).to.equal("26708488188717925");

              await network.provider.send("evm_increaseTime", [86400])  //1 day in seconds.
              await network.provider.send("evm_mine") // Increase time.

              const transactionCallAPI3 = await deployedMockGweiPump.manualUpKeep("8476500000")
              const tx_receiptCallAPI3 = await transactionCallAPI3.wait();
              expect(await deployedMockGweiPump.WtiPriceOracle()).to.equal("8476500000");
              expect(await deployedMockGweiPump.mockWti40Milliliters()).to.equal("26708488188717925");

            });
           });


});
