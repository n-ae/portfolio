// entity file
import { Prop } from '@nestjs/mongoose'

class MyEntity {
    @Prop({ required: true, type: String })
    myField!: string
}


// migration file
import { Connection } from 'mongoose'
import { IndexDescription } from 'mongodb'

async function up(connection: Connection): Promise<void> {
    const collection = connection.collection('orders')
    const indexes: IndexDescription[] = await collection.listIndexes().toArray()
    const uIndex = indexes.filter((index) => {
        const key: keyof MyEntity = 'myField'

        return index.unique && index.key.hasOwnProperty(key)
    })[0]

    if (uIndex.key === undefined) {
        throw Error
    }

    await collection.dropIndex(uIndex.name as string)
}
