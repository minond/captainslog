package query

import (
	"database/sql"
	"os"
	"reflect"
	"testing"

	txdb "github.com/DATA-DOG/go-txdb"

	"github.com/minond/captainslog/model"
)

func init() {
	txdb.Register("txdb",
		os.Getenv("DATABASE_DRIVER"),
		os.Getenv("DATABASE_CONN"))
}

func withDB(t *testing.T, fn func(*sql.DB)) {
	db, err := sql.Open("txdb", "TestExec")
	if err != nil {
		t.Fatalf("unable to open test database: %v", err)
		return
	}
	defer db.Close()

	fn(db)
}

func newUser(t *testing.T, db *sql.DB) *model.User {
	user, err := model.NewUser()
	if err != nil {
		t.Fatalf("error saving test user: %v", err)
	}
	if _, err = model.NewUserStore(db).Save(user); err != nil {
		t.Fatalf("error saving test user: %v", err)
	}
	return user
}

func TestExec(t *testing.T) {
	withDB(t, func(db *sql.DB) {
		store := model.NewEntryStore(db)
		user := newUser(t, db)
		sql := `select exercise as exercise where 1 = 0`
		cols, _, err := Exec(store, sql, user.GUID.String())
		if err != nil {
			t.Errorf("error: %v", err)
		}

		expected := []string{"exercise"}
		if !reflect.DeepEqual(expected, cols) {
			t.Errorf("expected %v but got %v", expected, cols)
		}
	})
}
