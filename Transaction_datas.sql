CREATE DATABASE Blog;
GO
USE Blog;
GO
CREATE TABLE Users (
	Id int PRIMARY KEY IDENTITY (1, 1),
	LoginName nvarchar(50) NOT NULL UNIQUE,
	Pswd nvarchar(200) NOT NULL,
	Rating float NOT NULL DEFAULT (0)
);
GO
CREATE TABLE Posts (
	Id int PRIMARY KEY IDENTITY (1, 1),
	IdUser int NOT NULL FOREIGN KEY REFERENCES Users(Id),
	Msg nvarchar(max) NOT NULL,
	DatePost datetime2 NOT NULL DEFAULT (SYSDATETIME()),
	Rating float NOT NULL DEFAULT (0)
);
GO
CREATE TABLE Comments (
	Id int PRIMARY KEY IDENTITY (1, 1),
	IdPost int NOT NULL FOREIGN KEY REFERENCES Posts(Id),
	IdUser int NOT NULL FOREIGN KEY REFERENCES Users(Id),
	Msg nvarchar(max) NOT NULL,
	DateComment datetime2 NOT NULL DEFAULT (SYSDATETIME()),
	Rating float NOT NULL DEFAULT (0)	
);
GO
CREATE TABLE PostRating (
	IdPost int NOT NULL FOREIGN KEY REFERENCES Posts(Id),
	IdUser int NOT NULL FOREIGN KEY REFERENCES Users(Id),
	Mark int NOT NULL,
	CONSTRAINT UQ_PostRating UNIQUE (IdPost, IdUser)
);
GO
CREATE TABLE CommentRating (
	IdComment int NOT NULL FOREIGN KEY REFERENCES Comments(Id),
	IdUser int NOT NULL FOREIGN KEY REFERENCES Users(Id),
	Mark int NOT NULL,
	CONSTRAINT UQ_CommentRating UNIQUE (IdComment, IdUser)
);

GO
SET IDENTITY_INSERT Users ON;
INSERT INTO Users (Id, LoginName, Pswd, Rating)
VALUES (1, N'User1', N'Pswd1', 4.5), (2, N'User2', N'Pswd2', 3), (3, N'User3', N'Pswd3', 0);
SET IDENTITY_INSERT Users OFF;
GO
SET IDENTITY_INSERT Posts ON;
INSERT INTO Posts (Id, IdUser, Msg, Rating)
VALUES (1, 1, N'Post_1_1', 4.5), (2, 1, N'Post_1_2', 4.5), (3, 2, N'Post_2_1', 2), (4, 2, N'Post_2_2', 4);
SET IDENTITY_INSERT Posts OFF;
GO
SET IDENTITY_INSERT Comments ON;
INSERT INTO Comments (Id, IdUser, IdPost, Msg)
VALUES (1, 3, 1, N'Message_3_1_1'), (2, 3, 2, N'Message_3_2_1'), (3, 2, 1, N'Message_2_1_1'), 
(4, 2, 2, N'Message_2_2_1'), (5, 1, 1, N'Message_1_1_1'), (6, 1, 3, N'Message_1_3_1'), 
(7, 3, 1, N'Message_3_1_2'), (8, 2, 3, N'Message_2_3_1'), (9, 1, 2, N'Message_2_2_1');
SET IDENTITY_INSERT Comments OFF;
GO
INSERT INTO PostRating (IdUser, IdPost, Mark)
VALUES (3, 1, 4), (3, 2, 5), (3, 3, 1), (3, 4, 4), (2, 1, 5), (2, 2, 4), (2, 3, 3), (2, 4, 4);
GO
