import type {
    Account,
    AccountClassification,
    AccountConnection,
    AccountType,
    Transaction,
    TransactionType,
    User,
} from '@prisma/client'

export type { Transaction }

export type TransactionEnriched = Transaction & {
    type: TransactionType
    userId: User['id']
    accountClassification: AccountClassification
    accountType: AccountType
}

export type TransactionWithAccountDetail = Transaction & {
    account: Account & {
        accountConnection: AccountConnection | null
    }
}

export type TransactionsResponse = {
    transactions: TransactionWithAccountDetail[]
    pageCount: number
}
