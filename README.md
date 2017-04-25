# Cloud Debug for Compute Engine sample
### cloud-debugger-gce-java-sample
This sample shows how to add the ability to debug your Java application running on [Google Compute Engine](https://cloud.google.com/compute/).  It is based on the [Spark Java](http://sparkjava.com/) - a tiny Sinatra inspired framework for creating web applications in Java 8.

This application just listens on port 8080 for requests and says "hello world" with a counter.  You can ask that a [Cloud Debugger](cloud.google.com/tools/cloud-debugger) snapshot be generated on any line.

### Preperation

1. Download & install the [Cloud SDK](https://cloud.google.com/sdk/)

1. Create a project (if you don't have one already) using the [Developers Console](https://cloud.google.com/console).
1. If you haven't already, use:

    `$ gcloud init`
    
1. Create a bucket (**Storage** > **Cloud Storage** > **Browser** > **Create bucket**)
or using the command line: 

    `$ gsutil mb <bucketName>`

1. Connect with your [Cloud Source Repository](https://cloud.google.com/tools/cloud-repositories/docs/) using:

    `$ gcloud beta source repos clone default <directoryName>`

1. Copy this project, skiping any .git files by using:

    `rsync -av --exclude=".*" <src> <directoryName>`
1. go into your directory: 

    `$ cd <directoryName>`

## Deploying

1. Commit and push the project to the Source Repository:

    `$ git add *`<br />
    `$ git commit -m 'Initial Commit'`<br />
    `$ git push origin master`
 
1. Build the project

    `$ mvn package -Dbucket=<bucketName>`

In addition to the normal compiling of classes and building of jars, we add to the **process-resources** phase the following:

`gcloud app gen-repo-info-file -\-output-file=target/project-1.0-SNAPSHOT/WEB-INF/classes/source-context.json`
    
Which helps tell the Cloud Debugger which version of your source code to associate with this execution as you can have many.

1. Deploy your application using:

    `$ mvn deploy -Dbucket=<bucketName>`

Deploy will first copy the startup script and the jar to the bucket using `gsutil`.  Then it will create a new instance using:

`gcloud compute instances create cdb --image debian-8 --metadata startup-script-url=gs://bucket/start.sh,my-bucket=gs://bucket  --scopes cloud-platform`

For this application, it is important that we use debian-8 (Jessie) as it will allow us to use Java 8 easily.

The startup script installs the Java 8 open jdk, uses update-alternatives to tell the system to default to Java 8 and gets a copy of the jar from the bucket.

The next steps are to setup the Cloud Debugger.  The first two lines get the latest version of the debugger bootstrap script and make it executable.

`wget -q https://storage.googleapis.com/cloud-debugger/compute-java/format_env_gce.sh`
`chmod +x format_env_gce.sh`

This next line executes that script passing a copy of the jar, and the return Java command line arguments

    CDBG_ARGS="$( sudo ./format_env_gce.sh --app_class_path=hellosparky-1.0-SNAPSHOT-jar-with-dependencies.jar )"

Finally we startup the code using, it will listen on port 8080:

    java ${CDBG_ARGS} -cp sparky/hellosparky-1.0-SNAPSHOT-jar-with-dependencies.jar com.example.hellosparky.App


## Run Locally

    java -cp target/hellosparky-1.0-SNAPSHOT-jar-with-dependencies.jar com.example.hellosparky.App

1. Visit the application at [http://localhost:8080](http://localhost:8080).

## Contributing changes

* See [CONTRIBUTING.md](CONTRIBUTING.md)

## Licensing

* See [LICENSE](LICENSE)
