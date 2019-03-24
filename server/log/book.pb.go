// Code generated by protoc-gen-go. DO NOT EDIT.
// source: book.proto

package log

import proto "github.com/golang/protobuf/proto"
import fmt "fmt"
import math "math"

// Reference imports to suppress errors if they are not otherwise used.
var _ = proto.Marshal
var _ = fmt.Errorf
var _ = math.Inf

// This is a compile-time assertion to ensure that this generated file
// is compatible with the proto package it is being compiled against.
// A compilation error at this line likely means your copy of the
// proto package needs to be updated.
const _ = proto.ProtoPackageIsVersion2 // please upgrade the proto package

type Grouping int32

const (
	Grouping_NONE  Grouping = 0
	Grouping_HOUR  Grouping = 1
	Grouping_DAY   Grouping = 2
	Grouping_WEEK  Grouping = 3
	Grouping_MONTH Grouping = 4
	Grouping_YEAR  Grouping = 5
)

var Grouping_name = map[int32]string{
	0: "NONE",
	1: "HOUR",
	2: "DAY",
	3: "WEEK",
	4: "MONTH",
	5: "YEAR",
}
var Grouping_value = map[string]int32{
	"NONE":  0,
	"HOUR":  1,
	"DAY":   2,
	"WEEK":  3,
	"MONTH": 4,
	"YEAR":  5,
}

func (x Grouping) String() string {
	return proto.EnumName(Grouping_name, int32(x))
}
func (Grouping) EnumDescriptor() ([]byte, []int) {
	return fileDescriptor_book_8ed9771a94007d72, []int{0}
}

type Book struct {
	Guid                 string       `protobuf:"bytes,1,opt,name=guid,proto3" json:"guid,omitempty"`
	Name                 string       `protobuf:"bytes,2,opt,name=name,proto3" json:"name,omitempty"`
	Grouping             Grouping     `protobuf:"varint,3,opt,name=grouping,proto3,enum=log.Grouping" json:"grouping,omitempty"`
	Extractor            []*Extractor `protobuf:"bytes,4,rep,name=extractor,proto3" json:"extractor,omitempty"`
	XXX_NoUnkeyedLiteral struct{}     `json:"-"`
	XXX_unrecognized     []byte       `json:"-"`
	XXX_sizecache        int32        `json:"-"`
}

func (m *Book) Reset()         { *m = Book{} }
func (m *Book) String() string { return proto.CompactTextString(m) }
func (*Book) ProtoMessage()    {}
func (*Book) Descriptor() ([]byte, []int) {
	return fileDescriptor_book_8ed9771a94007d72, []int{0}
}
func (m *Book) XXX_Unmarshal(b []byte) error {
	return xxx_messageInfo_Book.Unmarshal(m, b)
}
func (m *Book) XXX_Marshal(b []byte, deterministic bool) ([]byte, error) {
	return xxx_messageInfo_Book.Marshal(b, m, deterministic)
}
func (dst *Book) XXX_Merge(src proto.Message) {
	xxx_messageInfo_Book.Merge(dst, src)
}
func (m *Book) XXX_Size() int {
	return xxx_messageInfo_Book.Size(m)
}
func (m *Book) XXX_DiscardUnknown() {
	xxx_messageInfo_Book.DiscardUnknown(m)
}

var xxx_messageInfo_Book proto.InternalMessageInfo

func (m *Book) GetGuid() string {
	if m != nil {
		return m.Guid
	}
	return ""
}

func (m *Book) GetName() string {
	if m != nil {
		return m.Name
	}
	return ""
}

func (m *Book) GetGrouping() Grouping {
	if m != nil {
		return m.Grouping
	}
	return Grouping_NONE
}

func (m *Book) GetExtractor() []*Extractor {
	if m != nil {
		return m.Extractor
	}
	return nil
}

func init() {
	proto.RegisterType((*Book)(nil), "log.Book")
	proto.RegisterEnum("log.Grouping", Grouping_name, Grouping_value)
}

func init() { proto.RegisterFile("book.proto", fileDescriptor_book_8ed9771a94007d72) }

var fileDescriptor_book_8ed9771a94007d72 = []byte{
	// 215 bytes of a gzipped FileDescriptorProto
	0x1f, 0x8b, 0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0xff, 0xe2, 0xe2, 0x4a, 0xca, 0xcf, 0xcf,
	0xd6, 0x2b, 0x28, 0xca, 0x2f, 0xc9, 0x17, 0x62, 0xce, 0xc9, 0x4f, 0x97, 0xe2, 0x4f, 0xad, 0x28,
	0x29, 0x4a, 0x4c, 0x2e, 0xc9, 0x2f, 0x82, 0x88, 0x4a, 0x71, 0xa7, 0x17, 0xe5, 0x97, 0x16, 0x40,
	0x38, 0x4a, 0xed, 0x8c, 0x5c, 0x2c, 0x4e, 0xf9, 0xf9, 0xd9, 0x42, 0x42, 0x5c, 0x2c, 0xe9, 0xa5,
	0x99, 0x29, 0x12, 0x8c, 0x0a, 0x8c, 0x1a, 0x9c, 0x41, 0x60, 0x36, 0x48, 0x2c, 0x2f, 0x31, 0x37,
	0x55, 0x82, 0x09, 0x22, 0x06, 0x62, 0x0b, 0x69, 0x72, 0x71, 0x80, 0xf5, 0x67, 0xe6, 0xa5, 0x4b,
	0x30, 0x2b, 0x30, 0x6a, 0xf0, 0x19, 0xf1, 0xea, 0xe5, 0xe4, 0xa7, 0xeb, 0xb9, 0x43, 0x05, 0x83,
	0xe0, 0xd2, 0x42, 0x3a, 0x5c, 0x9c, 0x70, 0xbb, 0x25, 0x58, 0x14, 0x98, 0x35, 0xb8, 0x8d, 0xf8,
	0xc0, 0x6a, 0x5d, 0x61, 0xa2, 0x41, 0x08, 0x05, 0x5a, 0x6e, 0x5c, 0x1c, 0x30, 0x33, 0x84, 0x38,
	0xb8, 0x58, 0xfc, 0xfc, 0xfd, 0x5c, 0x05, 0x18, 0x40, 0x2c, 0x0f, 0xff, 0xd0, 0x20, 0x01, 0x46,
	0x21, 0x76, 0x2e, 0x66, 0x17, 0xc7, 0x48, 0x01, 0x26, 0x90, 0x50, 0xb8, 0xab, 0xab, 0xb7, 0x00,
	0xb3, 0x10, 0x27, 0x17, 0xab, 0xaf, 0xbf, 0x5f, 0x88, 0x87, 0x00, 0x0b, 0x48, 0x30, 0xd2, 0xd5,
	0x31, 0x48, 0x80, 0x35, 0x89, 0x0d, 0xec, 0x31, 0x63, 0x40, 0x00, 0x00, 0x00, 0xff, 0xff, 0x77,
	0x87, 0x0d, 0x35, 0x09, 0x01, 0x00, 0x00,
}
