# Charity Impact Tracking Smart Contract

## Overview

The Charity Impact Tracking Smart Contract is a blockchain-based solution built on Stacks that enables transparent tracking of charitable donations and their real-world impact. This contract provides a comprehensive framework for donation management, impact verification, and charity accountability.

## Features

- **Transparent Donation Tracking**: All donations are recorded on-chain with complete transparency
- **Impact Reporting**: Charities can report measurable outcomes and impact metrics
- **Milestone Management**: Long-term project tracking with milestone-based reporting
- **Charity Verification**: Multi-level verification system with compliance scoring
- **Donor Profiles**: Track donor activity and contribution history
- **Fee Management**: Built-in fee structure with admin controls

## Contract Architecture

### Core Data Structures

- **Charities**: Registry of verified charitable organizations
- **Donations**: Individual donation records with verification status
- **Donation Impacts**: Detailed impact reporting for each donation
- **Project Milestones**: Long-term project tracking and completion verification
- **Charity Verifications**: Compliance and efficiency ratings
- **Donor Profiles**: Donor activity and preference tracking

### Key Constants

- **Minimum Donation**: 1 STX (1,000,000 microSTX)
- **Default Contract Fee**: 5%
- **Maximum Charities**: 1,000
- **Maximum Impact Score**: 100

## Getting Started

### Prerequisites

- Stacks blockchain development environment
- Clarity smart contract deployment tools
- STX tokens for testing and deployment

### Deployment

1. Clone the contract code
2. Deploy to Stacks testnet or mainnet
3. Initialize contract with admin privileges
4. Begin charity registration process

## Core Functions

### Charity Management

#### Register Charity
```clarity
(register-charity name description wallet-address verification-docs impact-category)
```
Registers a new charitable organization with the platform.

**Parameters:**
- `name`: Organization name (max 100 characters)
- `description`: Organization description (max 500 characters)
- `wallet-address`: Principal address for receiving donations
- `verification-docs`: Documentation reference (max 200 characters)
- `impact-category`: Category of charitable work (max 50 characters)

#### Deactivate Charity (Admin Only)
```clarity
(deactivate-charity charity-id)
```
Deactivates a charity from accepting new donations.

### Donation Management

#### Make Donation
```clarity
(make-donation charity-id amount purpose allocation-percentage)
```
Creates a new donation to a registered charity.

**Parameters:**
- `charity-id`: Target charity identifier
- `amount`: Donation amount in microSTX
- `purpose`: Donation purpose description (max 200 characters)
- `allocation-percentage`: Percentage of donation for specific purpose

#### Verify Donation (Admin Only)
```clarity
(verify-donation donation-id)
```
Admin function to verify legitimate donations.

### Impact Reporting

#### Report Donation Impact
```clarity
(report-donation-impact donation-id beneficiaries-reached impact-description evidence-hash impact-score measurable-outcomes)
```
Allows charities to report the impact of received donations.

**Parameters:**
- `donation-id`: Reference to specific donation
- `beneficiaries-reached`: Number of people helped
- `impact-description`: Detailed impact description (max 500 characters)
- `evidence-hash`: Hash of supporting evidence (64 characters)
- `impact-score`: Impact effectiveness score (0-100)
- `measurable-outcomes`: Quantifiable results (max 300 characters)

### Project Milestones

#### Add Project Milestone
```clarity
(add-project-milestone charity-id milestone-id description target-amount target-beneficiaries)
```
Creates milestone tracking for long-term projects.

#### Complete Milestone
```clarity
(complete-milestone charity-id milestone-id verification-evidence)
```
Marks a project milestone as completed with verification.

### Verification System

#### Update Charity Verification (Admin Only)
```clarity
(update-charity-verification charity-id verification-level transparency-score efficiency-rating)
```
Updates charity verification scores and compliance status.

**Verification Levels:**
- Level 1-2: Basic verification
- Level 3-5: Full compliance status
- Scores range from 0-100 for transparency and efficiency

## Read-Only Functions

### Query Functions

- `get-charity-info`: Retrieve charity details
- `get-donation-info`: Get donation record
- `get-donation-impact`: View impact reporting
- `get-charity-verification`: Check verification status
- `get-project-milestone`: View milestone progress
- `get-donor-profile`: Access donor activity
- `get-contract-stats`: Overall contract statistics
- `calculate-impact-efficiency`: Compute cost-per-beneficiary

## Error Codes

- `ERR-NOT-AUTHORIZED (100)`: Insufficient permissions
- `ERR-CHARITY-NOT-FOUND (101)`: Invalid charity ID
- `ERR-DONATION-NOT-FOUND (102)`: Invalid donation ID
- `ERR-INVALID-AMOUNT (103)`: Below minimum or invalid amount
- `ERR-CHARITY-ALREADY-EXISTS (104)`: Duplicate charity registration
- `ERR-INVALID-MILESTONE (105)`: Milestone error
- `ERR-MILESTONE-ALREADY-COMPLETED (106)`: Milestone already finished
- `ERR-INSUFFICIENT-FUNDS (107)`: Inadequate balance
- `ERR-INVALID-PERCENTAGE (108)`: Percentage out of range
- `ERR-CHARITY-NOT-ACTIVE (109)`: Charity deactivated
- `ERR-IMPACT-ALREADY-REPORTED (110)`: Impact already submitted
- `ERR-INVALID-BENEFICIARIES (111)`: Invalid beneficiary count
- `ERR-DONATION-ALREADY-EXISTS (112)`: Duplicate donation

## Security Features

### Access Control
- Owner-only administrative functions
- Charity-specific impact reporting rights
- Validation of all user inputs

### Financial Security
- Minimum donation requirements
- Automatic fee calculation and distribution
- Protected fund withdrawal mechanisms

### Data Integrity
- Immutable donation records
- Verification requirements for impact reporting
- Evidence hash storage for accountability

## Usage Examples

### For Donors

1. **Find a Charity**: Query registered charities and their verification status
2. **Make a Donation**: Send STX to support specific charitable causes
3. **Track Impact**: Monitor how your donations create real-world change
4. **View History**: Access complete donation history and impact reports

### For Charities

1. **Register Organization**: Submit verification documents and organizational details
2. **Receive Donations**: Accept transparent, tracked donations from the community
3. **Report Impact**: Document measurable outcomes and beneficiary assistance
4. **Manage Milestones**: Track long-term project progress and completion

### For Administrators

1. **Verify Charities**: Review and approve charitable organizations
2. **Monitor Compliance**: Track verification scores and audit requirements
3. **Manage Fees**: Adjust contract fee structure as needed
4. **Ensure Quality**: Deactivate non-compliant organizations

## Contract Economics

### Fee Structure
- Default contract fee: 5% of donation amount
- Fees support platform maintenance and verification processes
- Admin-adjustable up to maximum 10%

### Fund Flow
1. Donor sends full donation amount to contract
2. Contract deducts fee percentage
3. Net amount transferred to charity wallet
4. Fees retained for platform operations

## Development and Testing

### Local Development
1. Set up Stacks development environment
2. Use Clarinet for local testing and deployment
3. Test all functions with various scenarios
4. Verify error handling and edge cases

### Integration Testing
- Test charity registration and verification flow
- Validate donation processing and impact reporting
- Verify milestone tracking functionality
- Test administrative controls and permissions