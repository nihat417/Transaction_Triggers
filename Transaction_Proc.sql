CREATE PROCEDURE AddCommentMark
	@comid AS int,
	@userid AS int,
	@mark AS int
AS
BEGIN
	BEGIN TRAN CommentMark

	INSERT INTO CommentRating(IdComment, IdUser, Mark)
	VALUES (@comid, @userid, @mark)

	IF(@@ERROR != 0)
	BEGIN
		PRINT 'Error in insert'
		ROLLBACK TRAN CommentMark
	END
	ELSE
	BEGIN

		PRINT 'Insert ok'
		UPDATE Comments
		SET Rating = (
			SELECT CAST(SUM(Mark) AS float) / COUNT(*)
			FROM Comments INNER JOIN CommentRating
			ON Comments.Id = CommentRating.IdComment
			WHERE  Comments.Id = @comid
		)
		WHERE  Comments.Id = @comid



		IF(@@ERROR != 0)
		BEGIN
			PRINT 'Error in update'
			ROLLBACK TRAN CommentMark
		END
		ELSE
		BEGIN
			PRINT 'update ok'

			DECLARE @CommentSumRaiting float
			SELECT @CommentSumRaiting = AVG(Rating) FROM Comments WHERE IdUser = @userid

			DECLARE @PostSumRaiting float
			SELECT @PostSumRaiting = AVG(Rating) FROM Comments WHERE IdUser = @userid


			UPDATE Users 
			SET Rating =  (@CommentSumRaiting + @PostSumRaiting) / 2

			IF(@@ERROR != 0)
			BEGIN
				ROLLBACK TRAN CommentMark
				END
			ELSE
			BEGIN 
				COMMIT TRAN CommentMark
			END
		END
	END
END

EXEC AddCommentMark 2, 2, 6


---------------------------------------------


CREATE PROCEDURE AddPostMark
	@post AS int,
	@userid AS int,
	@mark AS int
AS
BEGIN
	BEGIN TRAN PostMark

	INSERT INTO PostRating(IdPost, IdUser, Mark)
	VALUES (@post, @userid, @mark)

	IF(@@ERROR != 0)
	BEGIN
		PRINT 'Error in insert'
		ROLLBACK TRAN PostRating
	END
	ELSE
	BEGIN

		PRINT 'Insert ok'
		UPDATE Posts
		SET Rating = (
			SELECT CAST(SUM(Mark) AS float) / COUNT(*)
			FROM Posts INNER JOIN PostRating
			ON Posts.Id = PostRating.IdPost
			WHERE  Posts.Id = @post
		)
		WHERE  Posts.Id = @post



		IF(@@ERROR != 0)
		BEGIN
			PRINT 'Error in update'
			ROLLBACK TRAN PostMark
		END
		ELSE
		BEGIN
			PRINT 'update ok'	
			DECLARE @CommentSumRaiting float
			SELECT @CommentSumRaiting = AVG(Rating) FROM Comments WHERE IdUser = @userid

			DECLARE @PostSumRaiting float
			SELECT @PostSumRaiting = AVG(Rating) FROM Comments WHERE IdUser = @userid


			UPDATE Users 
			SET Rating =  (@CommentSumRaiting + @PostSumRaiting) / 2

			IF(@@ERROR != 0)
			BEGIN
				ROLLBACK TRAN PostMark
				END
			ELSE
			BEGIN 
				COMMIT TRAN PostMark
			END
		END
	END
END



EXEC AddPostMark 2, 2, 6


