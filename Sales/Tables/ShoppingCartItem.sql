CREATE TABLE [Sales].[ShoppingCartItem] (
    [ShoppingCartItemID] INT           IDENTITY (1, 1) NOT NULL,
    [ShoppingCartID]     NVARCHAR (50) NOT NULL,
    [Quantity]           INT           NOT NULL,
    [ProductID]          INT           NOT NULL,
    [DateCreated]        DATETIME      NOT NULL,
    [ModifiedDate]       DATETIME      NOT NULL
);
GO

EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Primary key for ShoppingCartItem records.', @level0type = N'SCHEMA', @level0name = N'Sales', @level1type = N'TABLE', @level1name = N'ShoppingCartItem', @level2type = N'COLUMN', @level2name = N'ShoppingCartItemID';
GO

EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Shopping cart identification number.', @level0type = N'SCHEMA', @level0name = N'Sales', @level1type = N'TABLE', @level1name = N'ShoppingCartItem', @level2type = N'COLUMN', @level2name = N'ShoppingCartID';
GO

EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Product quantity ordered.', @level0type = N'SCHEMA', @level0name = N'Sales', @level1type = N'TABLE', @level1name = N'ShoppingCartItem', @level2type = N'COLUMN', @level2name = N'Quantity';
GO

EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Product ordered. Foreign key to Product.ProductID.', @level0type = N'SCHEMA', @level0name = N'Sales', @level1type = N'TABLE', @level1name = N'ShoppingCartItem', @level2type = N'COLUMN', @level2name = N'ProductID';
GO

EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the time the record was created.', @level0type = N'SCHEMA', @level0name = N'Sales', @level1type = N'TABLE', @level1name = N'ShoppingCartItem', @level2type = N'COLUMN', @level2name = N'DateCreated';
GO

EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date and time the record was last updated.', @level0type = N'SCHEMA', @level0name = N'Sales', @level1type = N'TABLE', @level1name = N'ShoppingCartItem', @level2type = N'COLUMN', @level2name = N'ModifiedDate';
GO

EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Contains online customer orders until the order is submitted or cancelled.', @level0type = N'SCHEMA', @level0name = N'Sales', @level1type = N'TABLE', @level1name = N'ShoppingCartItem';
GO

CREATE NONCLUSTERED INDEX [IX_ShoppingCartItem_ShoppingCartID_ProductID]
    ON [Sales].[ShoppingCartItem]([ShoppingCartID] ASC, [ProductID] ASC);
GO

EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nonclustered index.', @level0type = N'SCHEMA', @level0name = N'Sales', @level1type = N'TABLE', @level1name = N'ShoppingCartItem', @level2type = N'INDEX', @level2name = N'IX_ShoppingCartItem_ShoppingCartID_ProductID';
GO

ALTER TABLE [Sales].[ShoppingCartItem]
    ADD CONSTRAINT [DF_ShoppingCartItem_Quantity] DEFAULT ((1)) FOR [Quantity];
GO

EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Default constraint value of 1', @level0type = N'SCHEMA', @level0name = N'Sales', @level1type = N'TABLE', @level1name = N'ShoppingCartItem', @level2type = N'CONSTRAINT', @level2name = N'DF_ShoppingCartItem_Quantity';
GO

ALTER TABLE [Sales].[ShoppingCartItem]
    ADD CONSTRAINT [DF_ShoppingCartItem_ModifiedDate] DEFAULT (getdate()) FOR [ModifiedDate];
GO

EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Default constraint value of GETDATE()', @level0type = N'SCHEMA', @level0name = N'Sales', @level1type = N'TABLE', @level1name = N'ShoppingCartItem', @level2type = N'CONSTRAINT', @level2name = N'DF_ShoppingCartItem_ModifiedDate';
GO

ALTER TABLE [Sales].[ShoppingCartItem]
    ADD CONSTRAINT [DF_ShoppingCartItem_DateCreated] DEFAULT (getdate()) FOR [DateCreated];
GO

EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Default constraint value of GETDATE()', @level0type = N'SCHEMA', @level0name = N'Sales', @level1type = N'TABLE', @level1name = N'ShoppingCartItem', @level2type = N'CONSTRAINT', @level2name = N'DF_ShoppingCartItem_DateCreated';
GO

ALTER TABLE [Sales].[ShoppingCartItem]
    ADD CONSTRAINT [PK_ShoppingCartItem_ShoppingCartItemID] PRIMARY KEY CLUSTERED ([ShoppingCartItemID] ASC);
GO

EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Primary key (clustered) constraint', @level0type = N'SCHEMA', @level0name = N'Sales', @level1type = N'TABLE', @level1name = N'ShoppingCartItem', @level2type = N'CONSTRAINT', @level2name = N'PK_ShoppingCartItem_ShoppingCartItemID';
GO

ALTER TABLE [Sales].[ShoppingCartItem]
    ADD CONSTRAINT [CK_ShoppingCartItem_Quantity] CHECK ([Quantity]>=(1));
GO

EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Check constraint [Quantity] >= (1)', @level0type = N'SCHEMA', @level0name = N'Sales', @level1type = N'TABLE', @level1name = N'ShoppingCartItem', @level2type = N'CONSTRAINT', @level2name = N'CK_ShoppingCartItem_Quantity';
GO

ALTER TABLE [Sales].[ShoppingCartItem]
    ADD CONSTRAINT [FK_ShoppingCartItem_Product_ProductID] FOREIGN KEY ([ProductID]) REFERENCES [Production].[Product] ([ProductID]);
GO

EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key constraint referencing Product.ProductID.', @level0type = N'SCHEMA', @level0name = N'Sales', @level1type = N'TABLE', @level1name = N'ShoppingCartItem', @level2type = N'CONSTRAINT', @level2name = N'FK_ShoppingCartItem_Product_ProductID';
GO

