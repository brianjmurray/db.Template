CREATE TABLE [Purchasing].[Vendor] (
    [BusinessEntityID]        INT                   NOT NULL,
    [AccountNumber]           [dbo].[AccountNumber] NOT NULL,
    [Name]                    [dbo].[Name]          NOT NULL,
    [CreditRating]            TINYINT               NOT NULL,
    [PreferredVendorStatus]   [dbo].[Flag]          NOT NULL,
    [ActiveFlag]              [dbo].[Flag]          NOT NULL,
    [PurchasingWebServiceURL] NVARCHAR (1024)       NULL,
    [ModifiedDate]            DATETIME              NOT NULL
);
GO

EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Primary key for Vendor records.  Foreign key to BusinessEntity.BusinessEntityID', @level0type = N'SCHEMA', @level0name = N'Purchasing', @level1type = N'TABLE', @level1name = N'Vendor', @level2type = N'COLUMN', @level2name = N'BusinessEntityID';
GO

EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Vendor account (identification) number.', @level0type = N'SCHEMA', @level0name = N'Purchasing', @level1type = N'TABLE', @level1name = N'Vendor', @level2type = N'COLUMN', @level2name = N'AccountNumber';
GO

EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Company name.', @level0type = N'SCHEMA', @level0name = N'Purchasing', @level1type = N'TABLE', @level1name = N'Vendor', @level2type = N'COLUMN', @level2name = N'Name';
GO

EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1 = Superior, 2 = Excellent, 3 = Above average, 4 = Average, 5 = Below average', @level0type = N'SCHEMA', @level0name = N'Purchasing', @level1type = N'TABLE', @level1name = N'Vendor', @level2type = N'COLUMN', @level2name = N'CreditRating';
GO

EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'0 = Do not use if another vendor is available. 1 = Preferred over other vendors supplying the same product.', @level0type = N'SCHEMA', @level0name = N'Purchasing', @level1type = N'TABLE', @level1name = N'Vendor', @level2type = N'COLUMN', @level2name = N'PreferredVendorStatus';
GO

EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'0 = Vendor no longer used. 1 = Vendor is actively used.', @level0type = N'SCHEMA', @level0name = N'Purchasing', @level1type = N'TABLE', @level1name = N'Vendor', @level2type = N'COLUMN', @level2name = N'ActiveFlag';
GO

EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Vendor URL.', @level0type = N'SCHEMA', @level0name = N'Purchasing', @level1type = N'TABLE', @level1name = N'Vendor', @level2type = N'COLUMN', @level2name = N'PurchasingWebServiceURL';
GO

EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date and time the record was last updated.', @level0type = N'SCHEMA', @level0name = N'Purchasing', @level1type = N'TABLE', @level1name = N'Vendor', @level2type = N'COLUMN', @level2name = N'ModifiedDate';
GO

ALTER TABLE [Purchasing].[Vendor]
    ADD CONSTRAINT [PK_Vendor_BusinessEntityID] PRIMARY KEY CLUSTERED ([BusinessEntityID] ASC);
GO

EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Primary key (clustered) constraint', @level0type = N'SCHEMA', @level0name = N'Purchasing', @level1type = N'TABLE', @level1name = N'Vendor', @level2type = N'CONSTRAINT', @level2name = N'PK_Vendor_BusinessEntityID';
GO


CREATE TRIGGER [Purchasing].[dVendor] ON [Purchasing].[Vendor] 
INSTEAD OF DELETE NOT FOR REPLICATION AS 
BEGIN
    DECLARE @Count int;

    SET @Count = @@ROWCOUNT;
    IF @Count = 0 
        RETURN;

    SET NOCOUNT ON;

    BEGIN TRY
        DECLARE @DeleteCount int;

        SELECT @DeleteCount = COUNT(*) FROM deleted;
        IF @DeleteCount > 0 
        BEGIN
            RAISERROR
                (N'Vendors cannot be deleted. They can only be marked as not active.', -- Message
                10, -- Severity.
                1); -- State.

        -- Rollback any active or uncommittable transactions
            IF @@TRANCOUNT > 0
            BEGIN
                ROLLBACK TRANSACTION;
            END
        END;
    END TRY
    BEGIN CATCH
        EXECUTE [dbo].[uspPrintError];

        -- Rollback any active or uncommittable transactions before
        -- inserting information in the ErrorLog
        IF @@TRANCOUNT > 0
        BEGIN
            ROLLBACK TRANSACTION;
        END

        EXECUTE [dbo].[uspLogError];
    END CATCH;
END;
GO

EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'INSTEAD OF DELETE trigger which keeps Vendors from being deleted.', @level0type = N'SCHEMA', @level0name = N'Purchasing', @level1type = N'TABLE', @level1name = N'Vendor', @level2type = N'TRIGGER', @level2name = N'dVendor';
GO

ALTER TABLE [Purchasing].[Vendor]
    ADD CONSTRAINT [FK_Vendor_BusinessEntity_BusinessEntityID] FOREIGN KEY ([BusinessEntityID]) REFERENCES [Person].[BusinessEntity] ([BusinessEntityID]);
GO

EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key constraint referencing BusinessEntity.BusinessEntityID', @level0type = N'SCHEMA', @level0name = N'Purchasing', @level1type = N'TABLE', @level1name = N'Vendor', @level2type = N'CONSTRAINT', @level2name = N'FK_Vendor_BusinessEntity_BusinessEntityID';
GO

EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Companies from whom Adventure Works Cycles purchases parts or other goods.', @level0type = N'SCHEMA', @level0name = N'Purchasing', @level1type = N'TABLE', @level1name = N'Vendor';
GO

ALTER TABLE [Purchasing].[Vendor]
    ADD CONSTRAINT [DF_Vendor_ActiveFlag] DEFAULT ((1)) FOR [ActiveFlag];
GO

EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Default constraint value of 1 (TRUE)', @level0type = N'SCHEMA', @level0name = N'Purchasing', @level1type = N'TABLE', @level1name = N'Vendor', @level2type = N'CONSTRAINT', @level2name = N'DF_Vendor_ActiveFlag';
GO

ALTER TABLE [Purchasing].[Vendor]
    ADD CONSTRAINT [DF_Vendor_ModifiedDate] DEFAULT (getdate()) FOR [ModifiedDate];
GO

EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Default constraint value of GETDATE()', @level0type = N'SCHEMA', @level0name = N'Purchasing', @level1type = N'TABLE', @level1name = N'Vendor', @level2type = N'CONSTRAINT', @level2name = N'DF_Vendor_ModifiedDate';
GO

ALTER TABLE [Purchasing].[Vendor]
    ADD CONSTRAINT [DF_Vendor_PreferredVendorStatus] DEFAULT ((1)) FOR [PreferredVendorStatus];
GO

EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Default constraint value of 1 (TRUE)', @level0type = N'SCHEMA', @level0name = N'Purchasing', @level1type = N'TABLE', @level1name = N'Vendor', @level2type = N'CONSTRAINT', @level2name = N'DF_Vendor_PreferredVendorStatus';
GO

ALTER TABLE [Purchasing].[Vendor]
    ADD CONSTRAINT [CK_Vendor_CreditRating] CHECK ([CreditRating]>=(1) AND [CreditRating]<=(5));
GO

EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Check constraint [CreditRating] BETWEEN (1) AND (5)', @level0type = N'SCHEMA', @level0name = N'Purchasing', @level1type = N'TABLE', @level1name = N'Vendor', @level2type = N'CONSTRAINT', @level2name = N'CK_Vendor_CreditRating';
GO

CREATE UNIQUE NONCLUSTERED INDEX [AK_Vendor_AccountNumber]
    ON [Purchasing].[Vendor]([AccountNumber] ASC);
GO

EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Unique nonclustered index.', @level0type = N'SCHEMA', @level0name = N'Purchasing', @level1type = N'TABLE', @level1name = N'Vendor', @level2type = N'INDEX', @level2name = N'AK_Vendor_AccountNumber';
GO

