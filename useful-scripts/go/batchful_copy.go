// This go script copies rows from one table to another by batches

package main

import (
	"database/sql"
	"fmt"
	"log"

	_ "github.com/lib/pq"
)

const (
	DB_DSN = "postgres://username:password@url.com:5432/dbName"
)

func main() {

	// Create DB pool
	db, err := sql.Open("postgres", DB_DSN)
	if err != nil {
		log.Fatal("Failed to open a DB connection: ", err)
	}
	defer db.Close()

	sqlString := `
		INSERT INTO tmp_tbl_name
		SELECT *
		FROM tbl_name
		WHERE '2021-11-11'::timestamp + $1 <= create_date_utc AND create_date_utc < '2021-11-12'::timestamp + $1
		ORDER BY create_date_utc
		LIMIT $2 OFFSET $3
		;
	`

	batch_size := 10000
	for j := 0; j < 13; j++ {
		duration := fmt.Sprintf("%d days", j)
		log.Println(duration)

		for i := 0; ; i += batch_size {
			res, err := db.Exec(sqlString, &duration, &batch_size, &i)
			if err != nil {
				log.Fatal("Failed to execute query: ", err)
			}
			aff, _ := res.RowsAffected()
			log.Println(aff)
			if aff < int64(batch_size) {
				break
			}
		}
	}
}
