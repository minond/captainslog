package assets

import (
	"bytes"
	"errors"
	"fmt"
	"io"
	"net/http"
	"os"
	"time"
)

// dir meets the http.FileSystem interface.
type dir struct {
	path     string
	contents map[string]http.File
}

var _ http.FileSystem = &dir{}

func Dir(path string) *dir {
	return &dir{path: path, contents: make(map[string]http.File)}
}

func (d *dir) Mount(f *file) *dir {
	d.contents[f.name] = f
	return d
}

func (d *dir) Open(path string) (http.File, error) {
	fullpath := d.path + path
	fmt.Printf("searching for %s\n", fullpath)

	// Does this file exists? If so, return the real thing
	if _, err := os.Stat(fullpath); !os.IsNotExist(err) {
		f, err := os.Open(fullpath)
		if err != nil {
			return nil, err
		}
		d.contents[path] = f
		return f, nil
	}

	// Return the in-memory version if that exists
	if f, exist := d.contents[path]; exist {
		return f, nil
	}

	// Otherwise return file not found error
	return nil, errors.New("file not found")
}

// file meets the os.FileInfo and http.File interfaces.
type file struct {
	name     string
	closed   bool
	size     int64
	offset   int64
	mode     os.FileMode
	modified time.Time
	bytes.Buffer
}

var _ os.FileInfo = &file{}
var _ http.File = &file{}

func File(name string, size int64, mode os.FileMode, modified time.Time, contents []byte) *file {
	f := &file{name: name, size: size, mode: mode, modified: modified}
	f.Write(contents)
	return f
}

// Close closes the file; subsequent reads will return no bytes and EOF.
func (f *file) Close() error {
	f.closed = true
	return nil
}

func (f *file) Stat() (os.FileInfo, error) {
	return f, nil
}

func (f *file) Readdir(c int) ([]os.FileInfo, error) {
	return nil, nil
}

// Seeker is the interface that wraps the basic Seek method.
//
// Seek sets the offset for the next Read or Write to offset, interpreted
// according to whence: SeekStart means relative to the start of the file,
// SeekCurrent means relative to the current offset, and SeekEnd means relative
// to the end. Seek returns the new offset relative to the start of the file
// and an error, if any.
//
// Seeking to an offset before the start of the file is an error. Seeking to
// any positive offset is legal, but the behavior of subsequent I/O operations
// on the underlying object is implementation-dependent.
//
// SeekStart   = 0 // seek relative to the origin of the file
// SeekCurrent = 1 // seek relative to the current offset
// SeekEnd     = 2 // seek relative to the end
func (f *file) Seek(offset int64, whence int) (int64, error) {
	switch whence {
	case io.SeekStart:
		f.offset = offset
	case io.SeekCurrent:
		f.offset += offset
	case io.SeekEnd:
		f.offset = f.size - offset
	}
	return f.offset, nil
}

func (f *file) Name() string       { return f.name }
func (f *file) Size() int64        { return f.size }
func (f *file) Mode() os.FileMode  { return f.mode }
func (f *file) ModTime() time.Time { return f.modified }
func (f *file) IsDir() bool        { return false }
func (f *file) Sys() interface{}   { return nil }
