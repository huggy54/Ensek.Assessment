CREATE TABLE [dbo].[Meter_Readings](
	[AccountId] [int] NOT NULL FOREIGN KEY REFERENCES dbo.Test_Accounts([AccountId]),
	[MeterReadingDateTime] [datetime2](7) NOT NULL,
	[MeterReadValue] [float] NOT NULL,
 CONSTRAINT [PK_Meter_Readings] PRIMARY KEY CLUSTERED 
(
	[AccountId] ASC,
	[MeterReadingDateTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Meter_Readings]  WITH CHECK ADD FOREIGN KEY([AccountId])
REFERENCES [dbo].[Test_Accounts] ([AccountId])
GO