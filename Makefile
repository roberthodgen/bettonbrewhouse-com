.PHONY: deploy

deploy:
	aws s3 cp index.html s3://bettonbrewhouse-com/index.html --profile personal-prod
	aws s3 cp images s3://bettonbrewhouse-com/images --recursive --profile personal-prod
	aws cloudfront create-invalidation --distribution-id E325XGV5XOOLEF --paths "/" "/*" --no-cli-pager --profile personal-prod 
