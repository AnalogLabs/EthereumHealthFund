# Ethereum Health Fund
## Global Health Services Marketplace
The Ethereum Health Fund (EHF) is a global health services marketplace that gives patients a wide selection of high-value health services and goods while freeing providers from administrative burdens that detract from patient care.

It provides a mechanism for financing health services and goods by leveraging elements of a health savings account, traditional health insurance, and cash-pay marketplaces.

## Case Study
A middle-aged woman enjoyed health insurance coverage for 20 years through her employer. During this time she was healthy and rarely used health services beyond occasional checkups. She recently lost her job, and then her coverage. A few months later she developed an autoimmune condition that began threatening her vision. Faced with a debilitating and costly medical problem, 20 years of insurance premiums did not help her in her time of need. 

## Problem 
Health insurance depends on healthier individuals subsidizing the healthcare costs of individuals with active medical problems. In a society without a universal (government) payer, high insurance premiums paid to private insurers do not build long term credit and cannot be used beyond a coverage network, limiting options available to patients, constraining the supply of available health services, and artificially elevating the cost of health services. 

## Summary of Proposed Solution
The Ethereum Health Fund (EHF) has 3 important features that address major shortcomings in the US healthcare system, and these features are enabled cost-effectively through a blockchain infrastructure:


1. Patients (and providers acting on their behalf) can open bids for health services and therapeutics, and providers/facilities can offer bids for services like prescription drugs, inpatient & outpatient services, procedures, imaging, and lab tests. 

2. EHF credits (digital tokens) can be purchased and used to pay for clinical services, diagnostic tests, and therapeutics by participating providers and facilities

3. EHF credits allow health systems & providers to design incentive programs that promote preventive healthcare, for example giving patients credits when they are proactive with preventive healthcare & allowing them to use these credits to subsidize healthcare costs


## Benefits to Healthcare Consumers

* EHF credits do not expire at the end of the year and can be used at any time.

* A bidding system on a public ledger creates competition among service providers and pharmaceutical companies, creating a race to the bottom for healthcare costs and a race to the top for health outcomes

- Opens more channels for patients to receive elective and non-elective services and therapeutics. More options results in greater market competition and lower costs.

* Transparency of prices 

## Benefits to Healthcare Providers

* Service providers get paid immediately via smart contracts and cryptocurrency without wasting time and resources on administratively burdensome functions such as:
    
    - prior authorizations
    - utilization review
    - late or delinquent payments for services rendered
    - applying to join each individual health insurance company's network


## Quickstart 
The EHF smart contract (ehf.sol) runs on the Ethereum Supercomputer and is the basis for this global health services marketplace. Analog Labs is currently running this on a private Ethereum network for small-scale pilots and will deploy to the main Ethereum network later this year.

To interface with the contract pythonically, first make sure you have the Go-Ethereum client (aka *geth*) installed on your machine and running in the background. The following code communicates with geth using an IPC socket.

```
cd /home/omar/ehf/simbel
python3

>>> from bcinterface import *
>>> bci = BCInterface(mainnet=False)  
>>> bci.load_contract(contract_name="ehf", contract_address="0xA87E48DC4D749B5e726Aa9cbaB1A026446e019e0")
>>> bci.howdyho()  # sanity check
```
### Managing Ethereum accounts
By default, the blockchain interface manager (BCInterface class) uses the zero-indexed Ethereum account. You can specify a different account and unlock accounts.
```
bci.set_account(1)  # use Ethereum account with index of 1 (i.e. second account)
bci.unlock_account()
```

### Create a new account:
```
bci.new_account()
```

## Health Marketplace Features
A *Request For Service (RFS)* is a bid for a health-related service such inpatient/outpatient services, diagnostic tests, and therapeutics. 

### Submit a Request For Service

```
bci.contract.transact(bci.tx).new_request_for_service()

Arguments:
	string _description,
	uint _max_amount (in wei, where 10**18 wei = 1 Ether),
	uint _bid_start_time (in UTC epoch seconds),
	uint _bid_end_time (in UTC epoch seconds),
```

Requests For Service are 2-dimensional data structures indexed first by the Ethereum address that submitted a RFS, and second by a zero-indexed list.

### Retrive a Request For Service
```
bci.contract.call().get_rfs( )

Arguments:
    address rfs_address,
    uint8 rfs_index,

Returns:
    string description,
    uint max_amount,  # maximum acceptable amount for a service/good
    uint bid_start_time,  # in UTC epoch seconds
    uint bid_end_time,    # in UTC epoch seconds
    address buyer,        # Ethereum address of party submitting RFS
    uint8 state,  # 0: open, 1: accepted, 2: executed, 3: canceled
    address lowest_bidder,  
    uint lowest_bid

```

### Query number of Requests For Service associated with user's Ethereum account
```
bci.contract.call().get_rfs_count()
 
Arguments:
    None 

Returns:
    uint count  # number of RFS associated with user's Ethereum address.

```

### Make an offer to a specific Request For Service
An offer consists of an amount of Ether (in wei) sent to the EHF contract, and the lowest bid at the end of the bidding period wins. Offers are associated with a specific RFS using the 2-index method described above.
```
bci.tx['value'] = 10**18  # for example, to offer a service for 1 Ether = 10**18 wei

bci.contract.transact(bci.tx).make_offer()

Arguments:
    address rfs_address,
    uint8 rfs_index

Returns:
    None
```

### Cancel a Request For Service
```
bci.contract.transact(bci.tx).cancel_rfs()

Arguments:
    uint8 rfs_index

Returns:
    None
```
### Withdraw an offer that was overbid
```
bci.contract.transact(bci.tx).withdraw()

Arguments:
    None

Returns:
    None
```

### End Request For Service bid and determine winner (lowest bid)
This method only establishes a winner (lowest bidder) but does not transfer funds.
```
bci.contract.transact(bci.tx).end_rfs_bid()

Arguments:
    address rfs_address,
    uint8 rfs_index

Returns:
    None
```
### Transfer funds to the winner of a Request For Service bid
This method can be called after the service/good is actually delivered (eg. on patient registration or pickup of a package).

```
bci.contract.transact(bci.tx).execute_rfs()

Arguments:
    address rfs_address,
    uint8 rfs_index

Returns:
    None

```
### Check Ether and token balances.
```
bci.contract.call().get_eth_balance("0x...")
bci.contract.call().get_token_balance("0x...")
```

### Set gas amount.
```
bci.set_gas()

Arguments:
    uint gas_amount

Returns:
    None
```

### Buy and sell token .
```
bci.tx['value'] = 10**18  # exchange one Ether for token at current exchange rate
bci.contract.transact(bci.tx).buy()
bci.contract.transact(bci.tx).sell(500)  # sell 500 tokens
```

## Deploying on a private network
The following steps are for users with a solid grasp of Ethereum development and networking, or who are motivated to put in the effort to learn. 

To run the Ethereum Health Fund on a private network, first run ```deploy.sh``` to compile the Ethereum Health Fund contract and generate the deployment script.
```
cd /home/omar/Desktop/ehf
./deploy.sh

Example contructor arguments: 10000000, "uht", "Universal Health Token"

```
* Note: * You may need to increase the gas value specified in ```/home/omar/Desktop/ehf/simbel/source/ehf.js``` to get the contract mined, depending on how your private network is configured.

Then start the private blockchain.
```
./load_privnet.sh
```
Unlock your Ethereum account and deploy the contract.
```
tmux a -t geth

personal.unlockAccount(eth.accounts[0])
loadScript('/home/omar/Desktop/fleetfox/simbel/source/ehf.js')
```

Make note of the address to which the contract is mined.

## Directory structure

The directory structure is important because Simbel and the Simbel Networking Utility look for certain files in certain directories. Your application will look something like this:
```
/your_working_directory
	README.md
	install.sh
	snu.sh
	deploy.sh
	log_nodeInfo.sh
	load_mainnet.sh
	load_privnet.sh 

	/simbel
		crypto.py
		genesis.json
		bcinterface.py
		fsinterface.py
		ipfs.py
		nodeInfo.ds
		
		/source
			ehf.sol
			ehf.bin
			ehf.abi

		/data_privnet
			/geth
			/keystore
			static-nodes.json

	/docs

```

The Ethereum Health Fund contract, ABI, and binary are located in the *source* directory.

## Contribute
Visit [Analog Labs](https://analog.earth) for more information about the Ethereum Health Fund and to apply to be a pilot site.

Please take a look at the [contribution documentation](https://github.com/simbel/simbel/blob/master/docs/CONTRIBUTING.md) for information on how to report bugs, suggest enhancements, and contribute code. If you or your organization use the Ethereum Health Fund to the benefit of patients, please share your experience!

## Code of conduct
In the interest of fostering an open and welcoming environment, we as contributors and maintainers pledge to making participation in our project and our community a harassment-free experience for everyone, regardless of age, body size, disability, ethnicity, gender identity and expression, level of experience, nationality, personal appearance, race, religion, or sexual identity and orientation. Read the full [Contributor Covenant](https://github.com/AnalogLabs/EthereumHealthFund/blob/master/docs/CODE_OF_CONDUCT.md). 

## Acknowledgements
This project builds on work by the [Ethereum](https://www.ethereum.org), [web3.py](https://github.com/pipermerriam/web3.py), [IPFS](https://github.com/ipfs/ipfs) and [py-ipfs](https://github.com/ipfs/py-ipfs-api) communities. 

## Analog Labs License
(C) 2018 [Omar Metwally, MD](omar@analog.earth)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

This work, and all derivatives of this work, must remain in the public domain.

Authors of commercial derivatives and applications of this work must offer to all members of the public the opportunity for stakeholdership in said works, in an equal and fair manner, in the form of ERC20-based token(s).

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

