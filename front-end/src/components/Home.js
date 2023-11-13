import React, { useEffect, useState } from "react";
import Likes from "../utils/Likes";
import Comments from "../utils/Comments";
import { useNavigate } from "react-router-dom";
import Nav from "./HomeNav";
import { Card, CardContent, CardHeader, Grid, Typography } from "@mui/material";

const Home = () => {
	const [postList, setPostList] = useState([]);
	const navigate = useNavigate();

	useEffect(() => {
		const checkUser = () => {
			if (!localStorage.getItem("_id")) {
				navigate("/");
			} else {
				fetch("http://localhost:4000/api/posts")
					.then((res) => {
						if (res.status === 200) {
							return res.json();
						}
						throw new Error("Something went wrong", res.json());
					})
					.then((data) => setPostList(data.posts))
					.catch((err) => console.error(err));
			}
		};
		checkUser();
	}, [navigate]);

	const getSubHeader = (post) => {
		return "posted by " + post.username + " on " + post.postedAt.year + "-" + post.postedAt.month + "-" + post.postedAt.day + " at " + post.postedAt.hour + ":" + post.postedAt.minute;
	}

	return (
		<div>
			<Nav />
			<div style={{ padding: 80 }}>
				<Grid container spacing={3} direction="column" alignItems="center" justify="center">
					{postList.map((post) => (
						<Grid item xs={12} key={post.id}>
							<Card sx={{ width: "1200px" }}>
								<CardHeader
									title={post.title}
									subheader={getSubHeader(post)}
									action={
										<div>
											<Likes
												numberOfLikes={post.likes.length}
												postId={post.id}
											/>
											<Comments
												numberOfComments={post.comments.length}
												postId={post.id}
												title={post.title}
											/>
										</div>
									}
								/>
								<CardContent>
									<Typography>
										{post.description}
									</Typography>
								</CardContent>
							</Card>
						</Grid>
					))}
				</Grid >
			</div>
		</div>
	);
};

export default Home;
