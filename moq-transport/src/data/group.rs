use crate::coding::{Decode, DecodeError, Encode, EncodeError};

#[derive(Clone, Debug)]
pub struct GroupHeader {
	// The subscribe ID.
	pub subscribe_id: u64,

	// The track alias.
	pub track_alias: u64,

	// The group sequence number
	pub group_id: u64,

	// The priority, where **smaller** values are sent first.
	pub send_order: u64,
}

impl Decode for GroupHeader {
	fn decode<R: bytes::Buf>(r: &mut R) -> Result<Self, DecodeError> {
		Ok(Self {
			subscribe_id: u64::decode(r)?,
			track_alias: u64::decode(r)?,
			group_id: u64::decode(r)?,
			send_order: u64::decode(r)?,
		})
	}
}

impl Encode for GroupHeader {
	fn encode<W: bytes::BufMut>(&self, w: &mut W) -> Result<(), EncodeError> {
		self.subscribe_id.encode(w)?;
		self.track_alias.encode(w)?;
		self.group_id.encode(w)?;
		self.send_order.encode(w)?;

		Ok(())
	}
}

#[derive(Clone, Debug)]
pub struct GroupObject {
	pub object_id: u64,
	pub size: usize,
}

impl Decode for GroupObject {
	fn decode<R: bytes::Buf>(r: &mut R) -> Result<Self, DecodeError> {
		let object_id = u64::decode(r)?;
		let size = usize::decode(r)?;

		Ok(Self { object_id, size })
	}
}

impl Encode for GroupObject {
	fn encode<W: bytes::BufMut>(&self, w: &mut W) -> Result<(), EncodeError> {
		self.object_id.encode(w)?;
		self.size.encode(w)?;

		Ok(())
	}
}
