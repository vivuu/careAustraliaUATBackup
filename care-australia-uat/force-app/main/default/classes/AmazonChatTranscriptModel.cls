public class AmazonChatTranscriptModel {

	public class Transcript {
		public String AbsoluteTime;
		public String ContentType;
		public String Id;
		public String Type;
		public String ParticipantId;
		public String DisplayName;
		public String ParticipantRole;
		public String Content;
	}

	public String Ver;
	public String AWSAccountId;
	public String InstanceId;
	public String InitialContactId;
	public String ContactId;
	public List<Participants> Participants;
	public List<Transcript> Transcript;

	public class Participants {
		public String ParticipantId;
	}
    
	public static AmazonChatTranscriptModel parse(String json) {
		return (AmazonChatTranscriptModel) System.JSON.deserialize(json, AmazonChatTranscriptModel.class);
	}
}