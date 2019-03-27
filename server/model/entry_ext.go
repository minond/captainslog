package model

import (
	"github.com/minond/captainslog/server/proto"
)

func (e Entry) ToProto() *proto.Entry {
	return &proto.Entry{
		Guid: e.Guid.String(),
		Text: e.Text,
		Data: e.Data,
	}
}
