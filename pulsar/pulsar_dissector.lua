pulsar_protocol = Proto("Pulsar", "Pulsar Protocol")

message_length = ProtoField.int32("pulsar.message_length", "messageLength", base.DEC)

pulsar_protocol.fields = {message_length}

local protobuf_dissector = Dissector.get("protobuf")

function pulsar_protocol.dissector(buffer, pinfo, tree)
    local offset = 0
    local remaining_len = buffer:len()
    local subtree = tree:add(pulsar_protocol, buffer(), "Pulsar Protocol Data")
    pinfo.cols.protocol = pulsar_protocol.name
    while remaining_len > 0 do
        if remaining_len < 4 then
            -- head not enough
            pinfo.desegment_offset = offset
            pinfo.desegment_len = DESEGMENT_ONE_MORE_SEGMENT
            return -1
        end
        local data_len = buffer(offset, 4):uint()
        if remaining_len - 4 < data_len then
            -- data not enough
            pinfo.desegment_offset = offset
            pinfo.desegment_len = data_len - (remaining_len - 4)
            return -1
        end
        local protobuf_len = buffer(offset + 4, 4):uint()
        subtree:add(message_length, buffer(offset, 4))
        pinfo.private["pb_msg_type"] = "message,pulsar.proto.BaseCommand"
        pcall(Dissector.call, protobuf_dissector, buffer(offset + 4, protobuf_len + 4):tvb(), pinfo, subtree)
        offset = offset + 4 + data_len
        remaining_len = remaining_len - 4 - data_len
    end
end

local tcp_port = DissectorTable.get("tcp.port")
tcp_port:add(6650, pulsar_protocol)
