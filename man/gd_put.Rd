% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/google_drive.R
\name{gd_put}
\alias{gd_put}
\title{Upload a file to Google Drive}
\usage{
gd_put(remote_ind, local_source = remote_ind, mock_get = c("copy",
  "move", "none"), on_exists = c("update", "replace", "stop"),
  type = NULL, verbose = FALSE,
  dry_put = getOption("scipiper.dry_put"),
  config_file = getOption("scipiper.gd_config_file"),
  ind_ext = getOption("scipiper.ind_ext"))
}
\arguments{
\item{remote_ind}{character name of the indicator file to write locally, but
which describes the status of the remote file once the file has been
uploaded by this function. The remote data file will have a name
corresponding to this ind_file (without the indicator extension, but with
same path and basename).}

\item{local_source}{character name of EITHER a data file to upload OR the
indicator file of a data file to upload. Using the same value for both
remote_ind and local_source (or setting local_source to the data file name
corresponding to the indicator in remote_ind) will only work (in remake) if
you are calling \code{gd_put} from within the same function that created the
data_file. If instead you have separate recipes for (a) creating the
original data_file, (b) posting the data_file, and (c) retrieving the
data_file from google drive, then the 'a' and 'c' recipes must have
different targets and this function's local_source argument should match
the target of the 'a' recipe while this function's remote_ind argument
should match the target of this recipe (=='b') and the data_file target of
the 'c' recipe. See the examples. Nonetheless, because we have commonly
adopted the 2-target option where remote_ind and local_source \emph{can} be the
same, the default for this argument is to set \code{local_source=remote_ind}.}

\item{mock_get}{character. if remote_ind and local_source imply different
local file locations, should the current local file (implied by
local_source) be left alone ('none'), or copied ('copy') or moved ('move')
to the location implied by remote_ind? If 'copy' or 'move' are used, and if
gd_get will be called in an upcoming command, this argument may help to
avoid an unnecessary download from Google Drive back to this computer
because \code{gd_get} skips the download if there's already a local file in the
right place with the right contents (MD5 hash).}

\item{on_exists}{what to do if the file already exists - update, replace, or
throw an error? The default is to update (using google drive's versioning
functionality). Note that while replacing might be cleaner than updating in
some ways, it has the drawback that only the owner (or Google Teams
organizer) of an item can delete it. Since 'replace' here means delete the
old file and post the new one, 'replace' doesn't work for collaboration on
standard Drive folders owned by a single person, unless only that owner
will ever be trying to replace the file in question.}

\item{type}{media type as passed to drive_upload or drive_update}

\item{verbose}{logical, used in gd_put and passed onto
googledrive::drive_update, drive_upload, and/or drive_rm}

\item{dry_put}{logical. If TRUE, calls to this function won't actually push
anything to Google Drive; they'll just pretend they've done it.}

\item{config_file}{character name of the YAML file containing
project-specific configuration information for Google Drive}

\item{ind_ext}{the indicator file extension to expect at the end of
remote_ind}
}
\description{
Upload (create or overwrite) a file to the project bucket and path. Writes an
indicator file exactly corresponding to the data_file path and name (but with
indicator file extension).
}
\examples{
\dontrun{
#### using 2 recipes

## remake file
# create and post 1_data/out/mydata.rds (and an indicator for it) at once
1_data/out/mydata.rds.ind:
  command: create_and_post_mydata(target_name)
# retrieve data file on demand
1_data/out/mydata.rds:
  command: gd_get('1_data/out/mydata.rds.ind')

## function definitions
create_and_post_mydata <- function(ind_file) {
  # create data file (no need to make indicator yet)
  data_file <- as_data_file(ind_file)
  mydata # <- ...compute mydata here...
  write.csv(mydata, data_file)
  # post and create indicator file
  gd_put(remote_ind=ind_file, local_source=data_file)
}

#### using 3 recipes

## remake file
# create 1_data/cache/mydata.rds (and an indicator for it) locally
1_data/tmp/mydata.rds.ind:
  command: create_mydata(target_name)
# post 1_data/cache/mydata.rds to 1_data/out/mydata.rds on Drive
1_data/out/mydata.rds.ind:
  command: gd_put(remote_ind=target_name, local_source='1_data/tmp/mydata.rds.ind')
# retrieve data file on demand
1_data/out/mydata.rds:
  command: gd_get('1_data/out/mydata.rds.ind')

## function definitions
create_mydata <- function(ind_file) {
  data_file <- as_data_file(ind_file)
  mydata # <- ...compute mydata here...
  write.csv(mydata, data_file)
  sc_indicate(ind_file, data_file=data_file)
}

}
}
