##################################################################################################
'''
Problem-2
---------
Code referenced from
1. http://scikit-learn.org/stable/auto_examples/cluster/plot_kmeans_digits.html
2. https://github.com/liviaalmeida/clustering/blob/master/PSO.py
3. StackOverflow, etc
'''
##################################################################################################


from sklearn.cluster import KMeans
from sklearn import metrics
from scipy.spatial.distance import cdist
import numpy as np
import matplotlib.pyplot as plt
from PSO import PSO, Inputs
import pandas as pd
from sklearn.decomposition import PCA as sklearnPCA
from sklearn.decomposition import PCA

def convert(imgf, labelf, outf, n):
    f = open(imgf, "rb")
    o = open(outf, "w")
    l = open(labelf, "rb")
    f.read(16)
    l.read(8)
    images = []

    for i in range(n):
        image = []
        for j in range(28*28):
            image.append("{0:.2f}".format(ord(f.read(1)) / 255.0, 2))
        image.append(ord(l.read(1)))
        images.append(image)

    for image in images:
        o.write(" ".join(str(pix) for pix in image)+"\n")
    f.close()
    o.close()
    l.close()

def PlotMnistData(x, y):
    ##########################################################################
    pca = sklearnPCA(n_components=2) #2-dimensional PCA
    transformed = pd.DataFrame(pca.fit_transform(x))
    trans = np.array([transformed[0],transformed[1],y])
    plt.scatter( trans[0][np.where( trans[2]=='0')], trans[1][np.where( trans[2]=='0')], label='Digit-0', c='red')
    plt.scatter( trans[0][np.where( trans[2]=='1')], trans[1][np.where( trans[2]=='1')], label='Digit-1', c='blue')
    plt.scatter( trans[0][np.where( trans[2]=='2')], trans[1][np.where( trans[2]=='2')], label='Digit-2', c='lightgreen')
    plt.scatter( trans[0][np.where( trans[2]=='3')], trans[1][np.where( trans[2]=='3')], label='Digit-3', c='cyan')
    plt.scatter( trans[0][np.where( trans[2]=='4')], trans[1][np.where( trans[2]=='4')], label='Digit-4', c='grey')
    plt.scatter( trans[0][np.where( trans[2]=='5')], trans[1][np.where( trans[2]=='5')], label='Digit-5', c='yellow')
    plt.scatter( trans[0][np.where( trans[2]=='6')], trans[1][np.where( trans[2]=='6')], label='Digit-6', c='violet')
    plt.scatter( trans[0][np.where( trans[2]=='7')], trans[1][np.where( trans[2]=='7')], label='Digit-7', c='orange')
    plt.scatter( trans[0][np.where( trans[2]=='8')], trans[1][np.where( trans[2]=='8')], label='Digit-8', c='pink')
    plt.scatter( trans[0][np.where( trans[2]=='9')], trans[1][np.where( trans[2]=='9')], label='Digit-9', c='black')
    plt.title('Scatter-plot representation of MNIST dataset(PCA reduced)')
    plt.legend()
    plt.show()
    ##########################################################################

def PlotElbowGraph(x, n_gen, max_k):
    ################################
    # create new plot and data
    plt.figure(2)
    plt.plot()
    # X = np.array(list(zip(x1, x2))).reshape(len(x1), 2)
    colors = ['b', 'g', 'r']
    markers = ['o', 'v', 's']

    # k means determine k
    distortions = []
    pso_centroids = []
    K = range(2, max_k)
    # PSO(20, 4, 0.9, 0.5, 1.5, 1.5, 5, x)
    for k in K:
        # def PSO(npart, k, in_max, in_min, c1, c2, maxit, x):
        centroid = PSO(len(x), k, 0.9, 0.5, 1.5, 1.5, n_gen, x)
        pso_centroids.append(centroid)
        temp = cdist(x, centroid, 'euclidean')
        distortions.append(sum(np.min(temp, axis=1)) / len(x))

    # Plot the elbow
    plt.plot(K, distortions, 'bx-')
    plt.xlabel('k values')
    plt.ylabel('Distortion')
    plt.title('Graph showing the optimal value of k at the elbow point')
    plt.show()
    return pso_centroids
    ################################

def VisualizeKMeans(x, c):
    #############################################################################
    ### Execution and Visualization of Kmeans on PCA transformed data.
    reduced_data = PCA(n_components=2).fit_transform(x)
    kmeans = KMeans(init='k-means++', n_clusters=c, n_init=10)
    kmeans.fit(reduced_data)
    # Step size of the mesh. Decrease to increase the quality of the VQ.
    h = .02     # point in the mesh [x_min, x_max]x[y_min, y_max].

    # Plot the decision boundary. For that, we will assign a color to each
    x_min, x_max = reduced_data[:, 0].min() - 1, reduced_data[:, 0].max() + 1
    y_min, y_max = reduced_data[:, 1].min() - 1, reduced_data[:, 1].max() + 1
    xx, yy = np.meshgrid(np.arange(x_min, x_max, h), np.arange(y_min, y_max, h))

    # Obtain labels for each point in mesh. Use last trained model.
    Z = kmeans.predict(np.c_[xx.ravel(), yy.ravel()])

    # Put the result into a color plot
    Z = Z.reshape(xx.shape)
    plt.figure(3)
    plt.clf()
    plt.imshow(Z, interpolation='nearest', extent=(xx.min(), xx.max(), yy.min(), yy.max()), cmap=plt.cm.Paired, aspect='auto', origin='lower')
    plt.plot(reduced_data[:, 0], reduced_data[:, 1], 'k.', markersize=2)
    # Plot the centroids as a white X
    centroids = kmeans.cluster_centers_
    plt.scatter(centroids[:, 0], centroids[:, 1], marker='x', s=169, linewidths=3, color='w', zorder=10)

    #pso_centroid = PCA(n_components=2).fit_transform(pso_centroids[c-2])
    #plt.scatter(pso_centroid[:, 0], pso_centroid[:, 1], marker='x', s=169, linewidths=3, color='b', zorder=10)
    #plt.title('K-means Vs PSO clustering on the MNIST digits dataset(PCA-reduced data)\n' 'K-Means centroids are marked with white cross and PSO with blue')
    plt.title('K-means clustering on the MNIST digits dataset(PCA-reduced data)\n' 'K-Means centroids are marked with white cross')
    plt.xlim(x_min, x_max)
    plt.ylim(y_min, y_max)
    plt.xticks(())
    plt.yticks(())
    plt.show()
    #############################################################################


if __name__ == '__main__':
    print "Hello"

    ### Change the parameters to get more accurate results.
    ###Parameters are kept small as large values can take time
    number_of_records_to_read = 50
    max_k = 6 # Algorithm will be executed for k=2 to max_k to find optimal k value; We can have large value of max_k but needs more computation
    n_gen_for_pso = 10 #number of generations for pso

    convert("train-images.idx3-ubyte", "train-labels.idx1-ubyte", "mnist_train.csv", number_of_records_to_read)
    x,y = Inputs("mnist_train.csv")

    PlotMnistData(x,y)
    pso_centroids = PlotElbowGraph(x, n_gen_for_pso, max_k)
    c = 4 # After Observing Elbow Graph we found optimal value of cluster count to be c
    VisualizeKMeans(x,c)
    ###Error analysis between Kmeans and PSO clustering
    kmeans1 = KMeans(init='k-means++', n_clusters=c, n_init=10)
    kmeans1.fit(x)
    c1 = PCA(n_components=1).fit_transform(kmeans1.cluster_centers_)
    c2 = PCA(n_components=1).fit_transform(pso_centroids[c-2])
    difference = c1-c2
    print difference
    print "Difference rate between KMeans and PSO clustering = " + str(np.mean(abs(difference)))
    ###END