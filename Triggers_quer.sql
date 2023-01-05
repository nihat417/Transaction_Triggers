--1.It was impossible to issue a book, which is no longer in the library (in quantity).

CREATE TRIGGER TeacherTakeBook_tr
ON T_Cards
AFTER INSERT
AS 
BEGIN
	DECLARE @book_id AS INT
	SELECT @book_id =Id_book from inserted

	DECLARE @quantity AS INT
	SELECT @quantity=B.[Quantity] FROM Books AS B
	WHERE B.Id=@book_id
	IF (@quantity=0)
	BEGIN
		ROLLBACK TRANSACTION
	END
	ELSE
	BEGIN
		UPDATE Books
		SET Quantity=Quantity-1
		WHERE Id=@book_id
	END
END

CREATE TRIGGER StudentTakeBook_tr
ON S_Cards
AFTER INSERT
AS 
BEGIN
	DECLARE @book_id AS INT
	SELECT @book_id =Id_book from inserted

	DECLARE @quantity AS INT
	SELECT @quantity=B.[Quantity] FROM Books AS B
	WHERE B.Id=@book_id
	IF (@quantity=0)
	BEGIN
		ROLLBACK TRANSACTION
	END
	ELSE
	BEGIN
		UPDATE Books
		SET Quantity=Quantity-1
		WHERE Id=@book_id
	END
END

SELECT *
FROM Students
INSERT INTO T_Cards([Id],[DateIn],[DateOut],[Id_Book],[Id_Lib],[Id_Teacher])
VALUES(555,'2000/03/01','2000/04/01',13,1,1)

--2.When you return a certain book, its quantity should increase

ALTER TRIGGER ReturnBook
ON S_Cards
AFTER UPDATE
AS
BEGIN
	DECLARE @book_id AS INT
	SELECT @book_id=Id_Book FROM inserted

	DECLARE @quantity AS INT
	SELECT @quantity=B.Quantity FROM Books AS B
	WHERE @book_id=B.Id

	DECLARE @return_date AS DATETIME
	SELECT @return_date=dateIn FROM S_Cards AS S
	WHERE @book_id=S.Id_Book
	
	DECLARE @time AS NVARCHAR(100)=CAST(@return_date AS NVARCHAR(100))
	IF (@time!='')
	BEGIN 
		PRINT 'Alredy this book returned'
		ROLLBACK TRANSACTION
	END

	ELSE
	BEGIN

		UPDATE S_Cards 
		SET DateIn=GETDATE()
		WHERE @book_id=Id_Book

		UPDATE Books
		SET Quantity=Quantity+1
		WHERE @book_id=Books.Id
	END
END

CREATE TRIGGER ReturnBookTeacher
ON T_Cards
AFTER UPDATE
AS
BEGIN
	DECLARE @book_id AS INT
	SELECT @book_id=Id_Book FROM inserted

	DECLARE @quantity AS INT
	SELECT @quantity=B.Quantity FROM Books AS B
	WHERE @book_id=B.Id

	DECLARE @return_date AS DATETIME
	SELECT @return_date=dateIn FROM T_Cards AS T
	WHERE @book_id=T.Id_Book
	
	DECLARE @time AS NVARCHAR(100)=CAST(@return_date AS NVARCHAR(100))
	IF (@time!='')
	BEGIN 
		PRINT 'Alredy this book returned'
		ROLLBACK TRANSACTION
	END

	ELSE
	BEGIN

		UPDATE S_Cards 
		SET DateIn=GETDATE()
		WHERE @book_id=Id_Book

		UPDATE Books
		SET Quantity=Quantity+1
		WHERE @book_id=Books.Id
	END
END

UPDATE S_Cards
SET DateIn=GETDATE()
WHERE Id=4

SELECT *
FROM S_Cards
INNER JOIN Books AS B ON B.Id=S_Cards.Id_Book

--3.When issuing a book, its quantity should decrease.

Create TRIGGER TakeBookTeacherInLibrary
ON T_Cards
AFTER INSERT
AS
BEGIN
	DECLARE @book_id AS INT
	SELECT @book_id=Id_Book FROM inserted

	DECLARE @quantity AS INT
	SELECT @quantity=Quantity FROM Books AS B
	WHERE B.Id=@book_id

	IF (@quantity=0)
	BEGIN
		PRINT 'This book in no longer available'
		ROLLBACK TRANSACTION
	END

	ELSE
	BEGIN
		UPDATE Books
		SET Quantity-=1
		WHERE Books.Id=@book_id
	END
END

Create TRIGGER TakeBookStudentInLibrary
ON S_Cards
AFTER INSERT
AS
BEGIN
	DECLARE @book_id AS INT
	SELECT @book_id=Id_Book FROM inserted

	DECLARE @quantity AS INT
	SELECT @quantity=Quantity FROM Books AS B
	WHERE B.Id=@book_id

	IF (@quantity=0)
	BEGIN
		PRINT 'This book in no longer available'
		ROLLBACK TRANSACTION
	END

	ELSE
	BEGIN
		UPDATE Books
		SET Quantity-=1
		WHERE Books.Id=@book_id
	END
END

SELECT * FROM S_Cards
SELECT * FROM Books
INSERT INTO S_Cards([Id],[Id_Student],[Id_Book],[DateOut],[Id_Lib])
VALUES(171,5,3,'2000/02/03',1)

SELECT *
FROM s_cards	


--4.. You can not give more than three books to one student in his arms.

ALTER TRIGGER CheckStudentBookCount
ON S_Cards
AFTER INSERT
AS 
BEGIN
	DECLARE @book_count AS INT
	DECLARE @book_id AS INT
	DECLARE @student_id AS INT
	DECLARE @quantity AS INT

	SELECT @student_id=Id_Student FROM inserted

	SELECT @book_count=COUNT(Id_Student)
	FROM S_Cards
	GROUP BY Id_Student
	HAVING @student_id=Id_Student

	IF (@book_count<=3)
	BEGIN 
		SELECT @book_id=Id_Book FROM inserted

		SELECT @quantity=Quantity 
		FROM Books AS B
		WHERE B.Id=@book_id

		IF (@quantity=0)
		BEGIN
			PRINT 'Alredy this book finished'
			ROLLBACK TRANSACTION
		END

		ELSE
		BEGIN
			UPDATE Books 
			SET Books.Quantity-=1
			WHERE @book_id=Books.Id
		END
	END

	ELSE
	BEGIN
		print 'You can get a maxiumum of 3 books'
		ROLLBACK TRANSACTION
	END
END

INSERT INTO S_Cards([Id],[Id_Student],[Id_Book],[DateOut],[Id_Lib])
VALUES(161,21,3,'2000/02/03',1)

--5.You can not issue a new book to a student, if he now read at least one book for more than 2 months.

ALTER TRIGGER CheckBookDate
ON S_Cards
AFTER INSERT
AS 
BEGIN
	
	DECLARE @date_out AS DATETIME
	DECLARE @date_in AS DATETIME
	DECLARE @student_id AS INT

	SELECT @date_out=DatEOut FROM inserted
	SELECT @date_in =DateIn FROM inserted
	SELECT @student_id=Id_Student FROM inserted
	
	DECLARE @check_date_in AS NVARCHAR(50)=CAST(@date_in AS NVARCHAR(50))


	IF EXISTS(SELECT DATEDIFF(DAY,@date_out,GETDATE()) FROM Students AS S 
	INNER JOIN S_Cards AS SC
	ON S.Id=SC.Id_Student
	WHERE S.Id=@student_id AND DateIn IS NULL AND DATEDIFF(DAY,@date_out,GETDATE())>60)
	BEGIN
		
			PRINT DATEDIFF(DAY,@date_out,GETDATE()) 
			PRINT 'Already you dont take book'
			ROLLBACK TRANSACTION
	END
	ELSE
	BEGIN
		PRINT 'you can take book successfully'
	END
END
