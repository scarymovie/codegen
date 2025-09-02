
  package asyncapi

  import (
    "encoding/json"

    "github.com/ThreeDotsLabs/watermill/message"
  )
  
    
    // AnonymousSchema_1 represents a AnonymousSchema_1 model.
type AnonymousSchema_1 struct {
  UserId string `json:"userId"`
  Username string `json:"username"`
  JoinedAt string `json:"joinedAt"`
  AdditionalProperties map[string]interface{} `json:"additionalProperties"`
}
    

// PayloadToMessage converts a payload to watermill message
func PayloadToMessage(i interface{}) (*message.Message, error) {
  var m message.Message

  b, err := json.Marshal(i)
  if err != nil {
    return nil, nil
  }
  m.Payload = b

  return &m, nil
}
  