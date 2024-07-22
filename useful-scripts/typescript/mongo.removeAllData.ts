import { INestApplication } from '@nestjs/common'
import { getConnectionToken } from '@nestjs/mongoose'
import { Connection } from 'mongoose'

export class IntegrationTestSetup {
    private app: INestApplication | undefined

    public async removeAllData() {
        const connection = await this.app.resolve<Connection>(getConnectionToken())
        const collections = await connection.db.collections()
        for (const collection of collections) {
            await collection.deleteMany({})
        }
        await connection.dropDatabase()
    }
}
