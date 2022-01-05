./data-update.sh;
Rscript Main.R;
rm Rplots.pdf;
git commit -am "Update Plot";
git push