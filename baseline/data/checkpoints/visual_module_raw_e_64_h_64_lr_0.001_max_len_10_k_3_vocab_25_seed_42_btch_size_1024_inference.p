��
l��F� j�P.�M�.�}q (X   protocol_versionqM�X   little_endianq�X
   type_sizesq}q(X   shortqKX   intqKX   longqKuu.�(X   moduleq cmodels.shapes_cnn
ShapesCNN
qXg   D:\OneDrive\Learning\University\Masters-UvA\Project AI\diagnostics-shapes\baseline\models\shapes_cnn.pyqX{  class ShapesCNN(nn.Module):
    def __init__(self, n_out_features):
        super().__init__()

        n_filters = 20

        self.conv_net = nn.Sequential(
            nn.Conv2d(3, n_filters, 3, stride=2),
            nn.BatchNorm2d(n_filters),
            nn.ReLU(),
            nn.Conv2d(n_filters, n_filters, 3, stride=2),
            nn.BatchNorm2d(n_filters),
            nn.ReLU(),
            nn.Conv2d(n_filters, n_filters, 3, stride=2),
            nn.BatchNorm2d(n_filters),
            nn.ReLU()
        )
        self.lin = nn.Sequential(nn.Linear(80, n_out_features), nn.ReLU())

        self._init_params()

    def _init_params(self):
        for m in self.modules():
            if isinstance(m, nn.Conv2d):
                nn.init.kaiming_normal_(m.weight, mode="fan_out", nonlinearity="relu")
            elif isinstance(m, nn.BatchNorm2d):
                nn.init.constant_(m.weight, 1)
                nn.init.constant_(m.bias, 0)

    def forward(self, x):
        batch_size = x.size(0)
        output = self.conv_net(x)
        output = output.view(batch_size, -1)
        output = self.lin(output)
        return output
qtqQ)�q}q(X   _backendqctorch.nn.backends.thnn
_get_thnn_function_backend
q)Rq	X   _parametersq
ccollections
OrderedDict
q)RqX   _buffersqh)RqX   _backward_hooksqh)RqX   _forward_hooksqh)RqX   _forward_pre_hooksqh)RqX   _state_dict_hooksqh)RqX   _load_state_dict_pre_hooksqh)RqX   _modulesqh)Rq(X   conv_netq(h ctorch.nn.modules.container
Sequential
qXQ   C:\Users\kztod\Anaconda3\envs\cee\lib\site-packages\torch\nn\modules\container.pyqX�	  class Sequential(Module):
    r"""A sequential container.
    Modules will be added to it in the order they are passed in the constructor.
    Alternatively, an ordered dict of modules can also be passed in.

    To make it easier to understand, here is a small example::

        # Example of using Sequential
        model = nn.Sequential(
                  nn.Conv2d(1,20,5),
                  nn.ReLU(),
                  nn.Conv2d(20,64,5),
                  nn.ReLU()
                )

        # Example of using Sequential with OrderedDict
        model = nn.Sequential(OrderedDict([
                  ('conv1', nn.Conv2d(1,20,5)),
                  ('relu1', nn.ReLU()),
                  ('conv2', nn.Conv2d(20,64,5)),
                  ('relu2', nn.ReLU())
                ]))
    """

    def __init__(self, *args):
        super(Sequential, self).__init__()
        if len(args) == 1 and isinstance(args[0], OrderedDict):
            for key, module in args[0].items():
                self.add_module(key, module)
        else:
            for idx, module in enumerate(args):
                self.add_module(str(idx), module)

    def _get_item_by_idx(self, iterator, idx):
        """Get the idx-th item of the iterator"""
        size = len(self)
        idx = operator.index(idx)
        if not -size <= idx < size:
            raise IndexError('index {} is out of range'.format(idx))
        idx %= size
        return next(islice(iterator, idx, None))

    def __getitem__(self, idx):
        if isinstance(idx, slice):
            return self.__class__(OrderedDict(list(self._modules.items())[idx]))
        else:
            return self._get_item_by_idx(self._modules.values(), idx)

    def __setitem__(self, idx, module):
        key = self._get_item_by_idx(self._modules.keys(), idx)
        return setattr(self, key, module)

    def __delitem__(self, idx):
        if isinstance(idx, slice):
            for key in list(self._modules.keys())[idx]:
                delattr(self, key)
        else:
            key = self._get_item_by_idx(self._modules.keys(), idx)
            delattr(self, key)

    def __len__(self):
        return len(self._modules)

    def __dir__(self):
        keys = super(Sequential, self).__dir__()
        keys = [key for key in keys if not key.isdigit()]
        return keys

    def forward(self, input):
        for module in self._modules.values():
            input = module(input)
        return input
qtqQ)�q }q!(hh	h
h)Rq"hh)Rq#hh)Rq$hh)Rq%hh)Rq&hh)Rq'hh)Rq(hh)Rq)(X   0q*(h ctorch.nn.modules.conv
Conv2d
q+XL   C:\Users\kztod\Anaconda3\envs\cee\lib\site-packages\torch\nn\modules\conv.pyq,X!  class Conv2d(_ConvNd):
    r"""Applies a 2D convolution over an input signal composed of several input
    planes.

    In the simplest case, the output value of the layer with input size
    :math:`(N, C_{\text{in}}, H, W)` and output :math:`(N, C_{\text{out}}, H_{\text{out}}, W_{\text{out}})`
    can be precisely described as:

    .. math::
        \text{out}(N_i, C_{\text{out}_j}) = \text{bias}(C_{\text{out}_j}) +
        \sum_{k = 0}^{C_{\text{in}} - 1} \text{weight}(C_{\text{out}_j}, k) \star \text{input}(N_i, k)


    where :math:`\star` is the valid 2D `cross-correlation`_ operator,
    :math:`N` is a batch size, :math:`C` denotes a number of channels,
    :math:`H` is a height of input planes in pixels, and :math:`W` is
    width in pixels.

    * :attr:`stride` controls the stride for the cross-correlation, a single
      number or a tuple.

    * :attr:`padding` controls the amount of implicit zero-paddings on both
      sides for :attr:`padding` number of points for each dimension.

    * :attr:`dilation` controls the spacing between the kernel points; also
      known as the à trous algorithm. It is harder to describe, but this `link`_
      has a nice visualization of what :attr:`dilation` does.

    * :attr:`groups` controls the connections between inputs and outputs.
      :attr:`in_channels` and :attr:`out_channels` must both be divisible by
      :attr:`groups`. For example,

        * At groups=1, all inputs are convolved to all outputs.
        * At groups=2, the operation becomes equivalent to having two conv
          layers side by side, each seeing half the input channels,
          and producing half the output channels, and both subsequently
          concatenated.
        * At groups= :attr:`in_channels`, each input channel is convolved with
          its own set of filters, of size:
          :math:`\left\lfloor\frac{C_\text{out}}{C_\text{in}}\right\rfloor`.

    The parameters :attr:`kernel_size`, :attr:`stride`, :attr:`padding`, :attr:`dilation` can either be:

        - a single ``int`` -- in which case the same value is used for the height and width dimension
        - a ``tuple`` of two ints -- in which case, the first `int` is used for the height dimension,
          and the second `int` for the width dimension

    .. note::

         Depending of the size of your kernel, several (of the last)
         columns of the input might be lost, because it is a valid `cross-correlation`_,
         and not a full `cross-correlation`_.
         It is up to the user to add proper padding.

    .. note::

        When `groups == in_channels` and `out_channels == K * in_channels`,
        where `K` is a positive integer, this operation is also termed in
        literature as depthwise convolution.

        In other words, for an input of size :math:`(N, C_{in}, H_{in}, W_{in})`,
        a depthwise convolution with a depthwise multiplier `K`, can be constructed by arguments
        :math:`(in\_channels=C_{in}, out\_channels=C_{in} \times K, ..., groups=C_{in})`.

    .. include:: cudnn_deterministic.rst

    Args:
        in_channels (int): Number of channels in the input image
        out_channels (int): Number of channels produced by the convolution
        kernel_size (int or tuple): Size of the convolving kernel
        stride (int or tuple, optional): Stride of the convolution. Default: 1
        padding (int or tuple, optional): Zero-padding added to both sides of the input. Default: 0
        dilation (int or tuple, optional): Spacing between kernel elements. Default: 1
        groups (int, optional): Number of blocked connections from input channels to output channels. Default: 1
        bias (bool, optional): If ``True``, adds a learnable bias to the output. Default: ``True``

    Shape:
        - Input: :math:`(N, C_{in}, H_{in}, W_{in})`
        - Output: :math:`(N, C_{out}, H_{out}, W_{out})` where

          .. math::
              H_{out} = \left\lfloor\frac{H_{in}  + 2 \times \text{padding}[0] - \text{dilation}[0]
                        \times (\text{kernel\_size}[0] - 1) - 1}{\text{stride}[0]} + 1\right\rfloor

          .. math::
              W_{out} = \left\lfloor\frac{W_{in}  + 2 \times \text{padding}[1] - \text{dilation}[1]
                        \times (\text{kernel\_size}[1] - 1) - 1}{\text{stride}[1]} + 1\right\rfloor

    Attributes:
        weight (Tensor): the learnable weights of the module of shape
                         (out_channels, in_channels, kernel_size[0], kernel_size[1]).
                         The values of these weights are sampled from
                         :math:`\mathcal{U}(-\sqrt{k}, \sqrt{k})` where
                         :math:`k = \frac{1}{C_\text{in} * \prod_{i=0}^{1}\text{kernel\_size}[i]}`
        bias (Tensor):   the learnable bias of the module of shape (out_channels). If :attr:`bias` is ``True``,
                         then the values of these weights are
                         sampled from :math:`\mathcal{U}(-\sqrt{k}, \sqrt{k})` where
                         :math:`k = \frac{1}{C_\text{in} * \prod_{i=0}^{1}\text{kernel\_size}[i]}`

    Examples::

        >>> # With square kernels and equal stride
        >>> m = nn.Conv2d(16, 33, 3, stride=2)
        >>> # non-square kernels and unequal stride and with padding
        >>> m = nn.Conv2d(16, 33, (3, 5), stride=(2, 1), padding=(4, 2))
        >>> # non-square kernels and unequal stride and with padding and dilation
        >>> m = nn.Conv2d(16, 33, (3, 5), stride=(2, 1), padding=(4, 2), dilation=(3, 1))
        >>> input = torch.randn(20, 16, 50, 100)
        >>> output = m(input)

    .. _cross-correlation:
        https://en.wikipedia.org/wiki/Cross-correlation

    .. _link:
        https://github.com/vdumoulin/conv_arithmetic/blob/master/README.md
    """
    def __init__(self, in_channels, out_channels, kernel_size, stride=1,
                 padding=0, dilation=1, groups=1, bias=True):
        kernel_size = _pair(kernel_size)
        stride = _pair(stride)
        padding = _pair(padding)
        dilation = _pair(dilation)
        super(Conv2d, self).__init__(
            in_channels, out_channels, kernel_size, stride, padding, dilation,
            False, _pair(0), groups, bias)

    @weak_script_method
    def forward(self, input):
        return F.conv2d(input, self.weight, self.bias, self.stride,
                        self.padding, self.dilation, self.groups)
q-tq.Q)�q/}q0(hh	h
h)Rq1(X   weightq2ctorch._utils
_rebuild_parameter
q3ctorch._utils
_rebuild_tensor_v2
q4((X   storageq5ctorch
FloatStorage
q6X   2224467057072q7X   cuda:0q8MNtq9QK (KKKKtq:(KK	KKtq;�h)Rq<tq=Rq>�h)Rq?�q@RqAX   biasqBh3h4((h5h6X   2224467054192qCX   cuda:0qDKNtqEQK K�qFK�qG�h)RqHtqIRqJ�h)RqK�qLRqMuhh)RqNhh)RqOhh)RqPhh)RqQhh)RqRhh)RqShh)RqTX   trainingqU�X   in_channelsqVKX   out_channelsqWKX   kernel_sizeqXKK�qYX   strideqZKK�q[X   paddingq\K K �q]X   dilationq^KK�q_X
   transposedq`�X   output_paddingqaK K �qbX   groupsqcKubX   1qd(h ctorch.nn.modules.batchnorm
BatchNorm2d
qeXQ   C:\Users\kztod\Anaconda3\envs\cee\lib\site-packages\torch\nn\modules\batchnorm.pyqfX#  class BatchNorm2d(_BatchNorm):
    r"""Applies Batch Normalization over a 4D input (a mini-batch of 2D inputs
    with additional channel dimension) as described in the paper
    `Batch Normalization: Accelerating Deep Network Training by Reducing Internal Covariate Shift`_ .

    .. math::

        y = \frac{x - \mathrm{E}[x]}{ \sqrt{\mathrm{Var}[x] + \epsilon}} * \gamma + \beta

    The mean and standard-deviation are calculated per-dimension over
    the mini-batches and :math:`\gamma` and :math:`\beta` are learnable parameter vectors
    of size `C` (where `C` is the input size). By default, the elements of :math:`\gamma` are sampled
    from :math:`\mathcal{U}(0, 1)` and the elements of :math:`\beta` are set to 0.

    Also by default, during training this layer keeps running estimates of its
    computed mean and variance, which are then used for normalization during
    evaluation. The running estimates are kept with a default :attr:`momentum`
    of 0.1.

    If :attr:`track_running_stats` is set to ``False``, this layer then does not
    keep running estimates, and batch statistics are instead used during
    evaluation time as well.

    .. note::
        This :attr:`momentum` argument is different from one used in optimizer
        classes and the conventional notion of momentum. Mathematically, the
        update rule for running statistics here is
        :math:`\hat{x}_\text{new} = (1 - \text{momentum}) \times \hat{x} + \text{momemtum} \times x_t`,
        where :math:`\hat{x}` is the estimated statistic and :math:`x_t` is the
        new observed value.

    Because the Batch Normalization is done over the `C` dimension, computing statistics
    on `(N, H, W)` slices, it's common terminology to call this Spatial Batch Normalization.

    Args:
        num_features: :math:`C` from an expected input of size
            :math:`(N, C, H, W)`
        eps: a value added to the denominator for numerical stability.
            Default: 1e-5
        momentum: the value used for the running_mean and running_var
            computation. Can be set to ``None`` for cumulative moving average
            (i.e. simple average). Default: 0.1
        affine: a boolean value that when set to ``True``, this module has
            learnable affine parameters. Default: ``True``
        track_running_stats: a boolean value that when set to ``True``, this
            module tracks the running mean and variance, and when set to ``False``,
            this module does not track such statistics and always uses batch
            statistics in both training and eval modes. Default: ``True``

    Shape:
        - Input: :math:`(N, C, H, W)`
        - Output: :math:`(N, C, H, W)` (same shape as input)

    Examples::

        >>> # With Learnable Parameters
        >>> m = nn.BatchNorm2d(100)
        >>> # Without Learnable Parameters
        >>> m = nn.BatchNorm2d(100, affine=False)
        >>> input = torch.randn(20, 100, 35, 45)
        >>> output = m(input)

    .. _`Batch Normalization: Accelerating Deep Network Training by Reducing Internal Covariate Shift`:
        https://arxiv.org/abs/1502.03167
    """

    @weak_script_method
    def _check_input_dim(self, input):
        if input.dim() != 4:
            raise ValueError('expected 4D input (got {}D input)'
                             .format(input.dim()))
qgtqhQ)�qi}qj(hh	h
h)Rqk(h2h3h4((h5h6X   2224467055728qlX   cuda:0qmKNtqnQK K�qoK�qp�h)RqqtqrRqs�h)Rqt�quRqvhBh3h4((h5h6X   2224467058608qwX   cuda:0qxKNtqyQK K�qzK�q{�h)Rq|tq}Rq~�h)Rq�q�Rq�uhh)Rq�(X   running_meanq�h4((h5h6X   2224467056304q�X   cuda:0q�KNtq�QK K�q�K�q��h)Rq�tq�Rq�X   running_varq�h4((h5h6X   2224467057360q�X   cuda:0q�KNtq�QK K�q�K�q��h)Rq�tq�Rq�X   num_batches_trackedq�h4((h5ctorch
LongStorage
q�X   2224467057456q�X   cuda:0q�KNtq�QK ))�h)Rq�tq�Rq�uhh)Rq�hh)Rq�hh)Rq�hh)Rq�hh)Rq�hh)Rq�hU�X   num_featuresq�KX   epsq�G>�����h�X   momentumq�G?�������X   affineq��X   track_running_statsq��ubX   2q�(h ctorch.nn.modules.activation
ReLU
q�XR   C:\Users\kztod\Anaconda3\envs\cee\lib\site-packages\torch\nn\modules\activation.pyq�X�  class ReLU(Threshold):
    r"""Applies the rectified linear unit function element-wise
    :math:`\text{ReLU}(x)= \max(0, x)`

    .. image:: scripts/activation_images/ReLU.png

    Args:
        inplace: can optionally do the operation in-place. Default: ``False``

    Shape:
        - Input: :math:`(N, *)` where `*` means, any number of additional
          dimensions
        - Output: :math:`(N, *)`, same shape as the input

    Examples::

        >>> m = nn.ReLU()
        >>> input = torch.randn(2)
        >>> output = m(input)
    """

    def __init__(self, inplace=False):
        super(ReLU, self).__init__(0., 0., inplace)

    def extra_repr(self):
        inplace_str = 'inplace' if self.inplace else ''
        return inplace_str
q�tq�Q)�q�}q�(hh	h
h)Rq�hh)Rq�hh)Rq�hh)Rq�hh)Rq�hh)Rq�hh)Rq�hh)Rq�hU�X	   thresholdq�G        X   valueq�G        X   inplaceq��ubX   3q�h+)�q�}q�(hh	h
h)Rq�(h2h3h4((h5h6X   2224467058896q�X   cuda:0q�MNtq�QK (KKKKtq�(K�K	KKtqh)Rq�tq�Rqňh)RqƇq�Rq�hBh3h4((h5h6X   2224467053040q�X   cuda:0q�KNtq�QK K�q�K�q͉h)Rq�tq�RqЈh)Rqчq�Rq�uhh)Rq�hh)Rq�hh)Rq�hh)Rq�hh)Rq�hh)Rq�hh)Rq�hU�hVKhWKhXKK�q�hZKK�q�h\K K �q�h^KK�q�h`�haK K �q�hcKubX   4q�he)�q�}q�(hh	h
h)Rq�(h2h3h4((h5h6X   2224467055152q�X   cuda:0q�KNtq�QK K�q�K�q�h)Rq�tq�Rq�h)Rq�q�Rq�hBh3h4((h5h6X   2224467058320q�X   cuda:0q�KNtq�QK K�q�K�q�h)Rq�tq�Rq��h)Rq��q�Rq�uhh)Rq�(h�h4((h5h6X   2224467057552q�X   cuda:0q�KNtq�QK K�q�K�q��h)Rr   tr  Rr  h�h4((h5h6X   2224467055824r  X   cuda:0r  KNtr  QK K�r  K�r  �h)Rr  tr	  Rr
  h�h4((h5h�X   2224467058704r  X   cuda:0r  KNtr  QK ))�h)Rr  tr  Rr  uhh)Rr  hh)Rr  hh)Rr  hh)Rr  hh)Rr  hh)Rr  hU�h�Kh�G>�����h�h�G?�������h��h��ubX   5r  h�)�r  }r  (hh	h
h)Rr  hh)Rr  hh)Rr  hh)Rr  hh)Rr  hh)Rr  hh)Rr   hh)Rr!  hU�h�G        h�G        h��ubX   6r"  h+)�r#  }r$  (hh	h
h)Rr%  (h2h3h4((h5h6X   2224467055248r&  X   cuda:0r'  MNtr(  QK (KKKKtr)  (K�K	KKtr*  �h)Rr+  tr,  Rr-  �h)Rr.  �r/  Rr0  hBh3h4((h5h6X   2224467057744r1  X   cuda:0r2  KNtr3  QK K�r4  K�r5  �h)Rr6  tr7  Rr8  �h)Rr9  �r:  Rr;  uhh)Rr<  hh)Rr=  hh)Rr>  hh)Rr?  hh)Rr@  hh)RrA  hh)RrB  hU�hVKhWKhXKK�rC  hZKK�rD  h\K K �rE  h^KK�rF  h`�haK K �rG  hcKubX   7rH  he)�rI  }rJ  (hh	h
h)RrK  (h2h3h4((h5h6X   2224467058800rL  X   cuda:0rM  KNtrN  QK K�rO  K�rP  �h)RrQ  trR  RrS  �h)RrT  �rU  RrV  hBh3h4((h5h6X   2224467057840rW  X   cuda:0rX  KNtrY  QK K�rZ  K�r[  �h)Rr\  tr]  Rr^  �h)Rr_  �r`  Rra  uhh)Rrb  (h�h4((h5h6X   2224467057936rc  X   cuda:0rd  KNtre  QK K�rf  K�rg  �h)Rrh  tri  Rrj  h�h4((h5h6X   2224467058992rk  X   cuda:0rl  KNtrm  QK K�rn  K�ro  �h)Rrp  trq  Rrr  h�h4((h5h�X   2224467058032rs  X   cuda:0rt  KNtru  QK ))�h)Rrv  trw  Rrx  uhh)Rry  hh)Rrz  hh)Rr{  hh)Rr|  hh)Rr}  hh)Rr~  hU�h�Kh�G>�����h�h�G?�������h��h��ubX   8r  h�)�r�  }r�  (hh	h
h)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hU�h�G        h�G        h��ubuhU�ubX   linr�  h)�r�  }r�  (hh	h
h)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  (X   0r�  (h ctorch.nn.modules.linear
Linear
r�  XN   C:\Users\kztod\Anaconda3\envs\cee\lib\site-packages\torch\nn\modules\linear.pyr�  XQ	  class Linear(Module):
    r"""Applies a linear transformation to the incoming data: :math:`y = xA^T + b`

    Args:
        in_features: size of each input sample
        out_features: size of each output sample
        bias: If set to False, the layer will not learn an additive bias.
            Default: ``True``

    Shape:
        - Input: :math:`(N, *, \text{in\_features})` where :math:`*` means any number of
          additional dimensions
        - Output: :math:`(N, *, \text{out\_features})` where all but the last dimension
          are the same shape as the input.

    Attributes:
        weight: the learnable weights of the module of shape
            :math:`(\text{out\_features}, \text{in\_features})`. The values are
            initialized from :math:`\mathcal{U}(-\sqrt{k}, \sqrt{k})`, where
            :math:`k = \frac{1}{\text{in\_features}}`
        bias:   the learnable bias of the module of shape :math:`(\text{out\_features})`.
                If :attr:`bias` is ``True``, the values are initialized from
                :math:`\mathcal{U}(-\sqrt{k}, \sqrt{k})` where
                :math:`k = \frac{1}{\text{in\_features}}`

    Examples::

        >>> m = nn.Linear(20, 30)
        >>> input = torch.randn(128, 20)
        >>> output = m(input)
        >>> print(output.size())
        torch.Size([128, 30])
    """
    __constants__ = ['bias']

    def __init__(self, in_features, out_features, bias=True):
        super(Linear, self).__init__()
        self.in_features = in_features
        self.out_features = out_features
        self.weight = Parameter(torch.Tensor(out_features, in_features))
        if bias:
            self.bias = Parameter(torch.Tensor(out_features))
        else:
            self.register_parameter('bias', None)
        self.reset_parameters()

    def reset_parameters(self):
        init.kaiming_uniform_(self.weight, a=math.sqrt(5))
        if self.bias is not None:
            fan_in, _ = init._calculate_fan_in_and_fan_out(self.weight)
            bound = 1 / math.sqrt(fan_in)
            init.uniform_(self.bias, -bound, bound)

    @weak_script_method
    def forward(self, input):
        return F.linear(input, self.weight, self.bias)

    def extra_repr(self):
        return 'in_features={}, out_features={}, bias={}'.format(
            self.in_features, self.out_features, self.bias is not None
        )
r�  tr�  Q)�r�  }r�  (hh	h
h)Rr�  (h2h3h4((h5h6X   2224467058128r�  X   cuda:0r�  M Ntr�  QK K@KP�r�  KPK�r�  �h)Rr�  tr�  Rr�  �h)Rr�  �r�  Rr�  hBh3h4((h5h6X   2224467052944r�  X   cuda:0r�  K@Ntr�  QK K@�r�  K�r�  �h)Rr�  tr�  Rr�  �h)Rr�  �r�  Rr�  uhh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hU�X   in_featuresr�  KPX   out_featuresr�  K@ubX   1r�  h�)�r�  }r�  (hh	h
h)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hU�h�G        h�G        h��ubuhU�ubuhU�ub.�]q (X   2224467052944qX   2224467053040qX   2224467054192qX   2224467055152qX   2224467055248qX   2224467055728qX   2224467055824qX   2224467056304qX   2224467057072q	X   2224467057360q
X   2224467057456qX   2224467057552qX   2224467057744qX   2224467057840qX   2224467057936qX   2224467058032qX   2224467058128qX   2224467058320qX   2224467058608qX   2224467058704qX   2224467058800qX   2224467058896qX   2224467058992qe.@       1����<�sa��|��(��=��=���;���=��>=��> x)=c)�=T�'��Po<E��=�h��|*>o�����L��<��T@=��=Y��=�|�;v�I=oo�=W��=Br/>h��=�5�=��=�Q\;D,�=��r���=wH�=g�����<���=cS�=�⬽��	>-#�������=���<�n���Q=0���:� ���=�{>� ռ�<���2�:�C�� �o�>p�񹕫O�#<���=���       ��=W.N�&BѽF.`;vZ���Ix=�_��՟½�c>���=rg�:��� ��=��+>��4>0�;/[z<n8μ�GA>*B�       �m3��#6>��0>!	�>�� =��J>�����=E�;��_��0�=� �=�8>�P����׽V�<xV�A6Z>��6>�6]>       ��g?T��?M��?I*�?@s�?cDZ? ��?�n?W��?dHn?1�?���?��u?=d�?L?|?z�?1y?ŀo?1ׂ?.��?      }o&<�!y�U�=�&����ؽ�<��>����=���;��j�oK= �U�CF�;�HH�kwl>ײ�>���?0/==������r�%=���=Rf� b�=�<��+���>��_>��q�D鑺��c>�iG=ڱ�=ҟ����*��#�~/T�e�]>�=�iI=I�G>}�ｴ�>�=�*J=(�T��4=k+=��� J��,�9=]ݧ��~�;�(����I��{>|��� ��~o���W>ZR�t��<7���g1}���=����J���1���>F��= �=��M�d>K<���f,��$*�=�e�<7����Lx����?V����b�	����|9�=����-�T��=Z�/=�,ս\lM�ݳ\=N�O���>y&���c�=o�����ٽŁ˼�%���>�['��d��"�9�3���1m>f[�h�\>D��Y[=�ac=U��VH!>#C=k�2>)�;<��<��C>���=�����n�[�������|½�==��=�Mh�W(=4�A��gT>��*>�L���䥾�������UT�d�/�@(b�r��.r>�~(>;q/��X�/.�=2[r==x�=0 Ͻ������u�^���z=��W����%�I�C:��Ú<��=�6����j�P/K��-
>�<ǕD�c�9���ٽ�/^�^+�=r���_i�a��(ӽ�.��C<��y�{�:�*0�pr>��=�#���2�=6����-��WO��W3�>YM�=�\������`;`�8��	>���=hCȽ<P(�\4�=/�־P>H>Kt,�~h�̃�=�7M�S��B�&�>�"=|P!>��S��:=ډ���OW�96U>����2��C޼m��<��0>�4��눽�U>=<,�;i�^>R�U�h�޽�jq�V�z== Z��h>ލ�<R0>fy2=�<ҏ%���>�BJ>�V�=e����E�=�R#>��'>%��u{F�M�a>�_���k%>��5��K�wސ�E�B�V̪=e份o<�Cj> P>ݤ�=�~==�;t���y;>᷎���ڽ�k>ԋ��yŏ>��7=�Xb>���z����`=���=����;��}ѽ�3�=�<I=yԧ����=�|��{>̵��)�伵�)������޽Hz:���?<Ʋ��}>\z�轟��Kn>�>����/�M�V=�u��<<\�>)YC>�.�=,"=�VĻz�S=9��>@<�w>Tǉ>Zj��q������>��=�)�>0(%�m�=�(>U�<�q���|>�?��_ֽ|[1��Y���k���O=�=0>��1=�`M>�ݨ�lXU��ż��+��=X$�L;>>�i)�9��#�=��>�q ���;���=��ʼb~>�E�>{��7í=�'�=Ϙ>�ɽ��)=W��>�/ջ�̉���U>5u�>�i	>�-���\�<�������5,�oY=M��=�א=�=�G����Z>���$�,���w<����ƀ=Mf#������6��eU�t��O)J���,<��>���:�A��ໞ��n�>�8=u�?�Wy����=�5����,>�zC���=I����q>"�[&;撽����н����i��=K�:��N>G`<4�=i9=�Sw�G�?�@:��ӵ�=~9>E�?�{�=�G;����IsW�I.ܽ�N�=͍,=	����=h�:��">4�3�����5v����>L�=j�=0�>�S\�;}�;f>v�;==��[[q;��p>y�=ٱ�=��<ATA���(��=�	4��5>�+>�G�A�ʽ�����ﳻ|4�=?¯��a	��f
=Zν����ak��n��{f\>����,�%����!*�=�@,>)�=䌽�B��� \>o������A�:B�O�A�9��=iF>�Rf>�<in=[��	z9��z<���8���M��=���	��<��=J�0�a_0�&�=�L?�w���M�I�EY��@O����>lXM��:�=k�>0��=�����L�|�=u��G)����=h�=�Z:[�,=�`���&�x�H��	��?7=���F�=�E	�i<����>l �=Q4C>�=�H�=���$׼�on���>�t���i��^�����=�ό��,=G�==آ����=ZN�����'��:ׯ=%��=�l�W��=u��9>�+�=�a>x���wU��&ѽT��Y��N�=�zo;�`>��=�@�=J��<����=Y����#����=n�=$D>�轄��О6<�Z'��������=b ؼE�E>��=�->�z�<�ٽ!of=-�=�,�0R�=hh�=��˽;��<ޭ%=0����=��n�o�<�	� �5>'��<���j��0�=u�=��ϣ�O-�=H�'>{`>F~�F(�;��=e"�QD�=4�ٽ�A�=��=Fn�>Ɍ�<�9�=����=g>��f�=��ֽ!>`������<��P>![ż�<di��3���9v=`��=+W>"�黲�9�8�U-�?'�=����}��mr����>$��O�B�%=�2^�B��()���{>.�;�J=
�j=��>l*=jD��=GB<N�|�������	���¾X�����=·:=}�޽ڎ��f�޽m	>H;����}=�����GD�ȇ�'N>_��<
��S{P;2��=/��>H���U��=��;�j4��c�<���YN)�R�<m:<�=t6\���=����s�=>��C)h����u&�=����%�4��q>�y�>�J�=�>�4���"<~������=e?=�}>�o��,=��>�Q���l>�P\��>]���j5g=�>�=%��Ɗ)=`ܮ=�^=�4$��:�<�c˼ �=�"@��\>JN�<]�$�����E
���*�����-(ʺn����\�=ZW���;,&A>c{�_�=Z�F��am=���ǃ�c*w�$sc=DՏ=���=N@>CL�=/�h�BT]�1?�<�%e>v�b�A��=,g�=�>���(:>��&�D.���<�œ=ńy��u4;�����4�=&W���=fv�=�L�cN�5��<�?����T��Ѐ=�j=<2�[6��qt+��]>0��=�� �2�<�+�=��<PF�e�F�j��k1�:�4<b ���@�=�iƽ�=�k�=2��=㋘=|��,Rt>E�T< &=��Y�7r��qp4�c�D>���>^U�=/i���=�� �?[�}�= 듽�Q�=΂Ծ��P�4{<ގ+=a)=�KN�)������O<���2������;�<�B5�n�k�W���y�H�<�=v��=j���羚=�Y�x޵���Ѿ�dZ��%�==�E=��;�ă=)|��7m<>����9t=W�>�2
=k>�C���Լ=��=�K=�l(�w��v�!��r.�s�ؼ/h��|n� �=�š=,�>Q�%=*gN>5�≠�>��՘*��!�9>SG�=��<R�!=k4���ɽ~i���#�^�ԼK$/����l�9^)T�U6>���=��S<�w�j�w��>�>.߂=6t��ri��
oM��
�����鲗����ms=N�;즙��ȽX^p=�7+=pN>�>(�DB�=�P>!н�߹���y���_�K�{c`=�?�
�u��3�>�*<�6�D��y=��WJ��<��<�<>t�=岽�{5��k>��!���O=���=|��=��>5y>S/i=�ka=�~>�Y����;���n�P�_b,=xxA��d�=��=����fZ=���66��LT��er��ҝ���ܽ;<p
��L��^P!>��>�X�=v�>P���S��+���8�=z�0�&G=Bb��Hq�'�r���ͽ��I=�<_��<~�8�A�^=�E&�e'����>Y�$=�H<[{��𕫽��O�x�<�f���\�=�%��{`<bL<���=3u����s7�����>��q���=�֟��\o=-NԼ=]׽�53��0��;D�>��>A|�=�t�8��=�<(@�=/�|=�\���]>8�v��@<<�Ѕ=�h�=�]B>���(:����kG>Z�V��T��O>#-����<���;6�t����<3�(>����C�q="6�=Yw�ZU5��i�_I=����oÊ>�p�=~Qp<��>F��>��񣔾Y�L��/>��E��p���-K<pX�<K�>�ꍬ��) = �U>�֔�ˀf�x$�Kn<���]��=#޽�"o�2��<���>I�{�o��=7�C�Py<�qོ��=�i*>�,^���>m��<�2��{>_�O�4C��*(�A�\�e>��4�S��=;k�=�3���=��i>5�S�0c�=��5�e�Q��ۈ��B�>�]=S>�d+,=�jD=��:���=[�=l���?<��=nc>��=��>*@Ƽ�]��ԛN=
���ܩ.���*���9e�+>�=}Ta��q�=�!�=�K�=�mH�Kl��!��C%H�8����5�=�s=;�K��A=ɩ3�o�=t�I<�O����=��f>�J2>K=ə��� 1== ���r��W2�=�۽�f��'5�=bȖ>1,=2�=���ʟ���`���P����B>Z�n���?=�r>:~�����L`������]�ٿ�Q�\��[���F�ùE=�:�^�>��s=�?q���T><�x>(O��*�>���e��`�<:��=��=�����L��J>@�N����<=2Ƚ�-@=��=�'H=<�������6���<��r�uvm<�{p=.6��}5���=�=3<x_>���=w;��$!>U��=�%�=eQt��+u<;q�=�	���<,�">�s=I���_m��W2>�0��O%�=��c���*=�	��FF=b�<Cr�=x��=,��)�,�r��Z~=�)7�r1l>F9>oA�<�}��yxż<z=�J��f(�C<�� >��=�#>։���R�[� >PN���5>wb>���<[f����=Smͽ$x���;����>���;X�=M8>��� >��=���=�i>w  =P�C��%>�W�=�'J>}2=���<e��t>MG��E"<����>0u=�D�=���</z=]�ؾ��<��~k;�k�����=�z�`�$=��,��l|��,Y��_a���=�*������$?<����L�=�0�<E8���#=�}>���<@	m=�!<ȼ�6�=�
>��n��!�,�">��QD@�n@�Ļ�<��h<���4���O���F�V<�
~��Y�o:M���=�.1�.Z=���K=."-=�=>�潂A�=@�>��j=�U�#���(˽�D�`�=�'>r�={~ڽ�C�=ca=G3��3	��O��=�0"��`k�I��:`rj�G�~�R��=)�l�K�=&�=LCL>�c���>�;�<�6>o�{�Fܬ�8_��+�>������¼L]�=��=[3<��=�>�=֛=�%=���=?�3Fc�����'=�	�0�=�淽2zP��u�=�=m��<�r�I��):R> ��=@�d�_'��md�=%Zz�=�=,:>�G�Hrk>w��SG��c�=ζi�)mL���f;9�k�7>J;��1����	0��rμd@=:�Ƚ/�H=	�7>r��=g�f`;=�;l3]=PȜ=����/����+:n>����@r��j���O�=,�0�V�%��v�=r:"�F���m�����>>+���"=�4�������4=H�="x(>����<_g�=�ヾ�d��!��u,��FTl>>���C�,>����i[<��X=��?��JĽ�� ���=�*����b�.�;@' �@��=�>!��<���=�%�d|>[�;=oOf�b��"8H���Խ�=�,�=�旽�s>P=c� �T���<��>�Q>g�8>n_v�� ν��N���<���ɟ���!=T=�
=�����=�½��Iw=�ߪ�s��=�Ǵ��c�=>΄�9�=�#ĻC>��A�[�B>11�����=���;��=��==�d?��Dw���X={.>9�I=�$��(�=�|�oc�=i�=���=�k�=9h�=�
-�v�=ɴ����=w�
< '��\�=��_>_��<�y[=����n���.�%���
<��D=a�0�ˮ�;��J���|��~�s�О��ӽ*��`0=D�_��Z��N;�[�.�sE��)>��0�����@l>�95���+��*�����<��=!�d=�'�:U[>�m<�G�=Wj�.l>�K��`"=����_B>j6Խ}�>�q �A�E�Z��=M�k=�>�x����=s����*?��!y����E~�& =>)ɯ��Y=�k�O�ȽX�;����< B>�3���G��E��f�><��7{�����JϽX-�<��x>�\l����=��w;�\�����c=Reݽ
I&�[@6�}�<���� �>x�>d%��?s��Z9������)=�a=z�u=pؾ;k�>kf�<.AE=|��=�;S�,���z�<޽">�`=Y����6=�6�=��ཏޥ=��t��=)����･D�>�3>j�����>�@=��&��􋽱=��]���'>tX%��^�3)�<W������;��ǽ�l�=�7c��j>���:@ϻ�����g�{���0>����E>Yžqmx>�>�b���	=���,�ϼ�Tսn>>>��\`>Cx��Ƞ�=�Z���	�s�=�����%� ½���=ᣪ=��Q��1�59�GW>��7�$y>X�ڽ]�=Rۊ=��=�;���S=<N�7���o"��ja<��;�E>�hj>��=�A��&��=?�C>(��=�i���Ѽb��<�6>��ɐZ�Z��='�9�׀��Et�/��6��<��= <*��f��g�&>{ɽ�·�4�=���:~��ݓ=-A��ML�i�=�>>E�>j����8��=)���^/>�J=�ݰ����0� ���8�VyR�4U��*��h�����i>�� �P`�<
�˽
h3=|ٳ�(� =��7�&)�a�T���^=���=U�{>�XK>]e����i=��">m��3a���h����<q���LL��=W�=)��=�&>=q�����5�7�>�T�3�	��n��v�H>�N>�w�x�����=�W���-����|�O��������R=��6��Xb�kL�<c3˼���=�sY>b'>��:q�K=c��=�tp�v<�<��/=@���Em�J���H:�(
���7cP;^;�u4�=���<�,}���K=��y�w$��k���k�=6���7>Iu>B(��7�����=�k>����J�=pQ>a��P=�>�p�ͽ	 ���l�=��>�p5��t��8��=�)��z�=)����C*��
o=y�=,�?;�X��ԕA�i������=�c>�1F��k�=�1�=Ӈ���=�C���J}<mx9>���<�����>�c�GB�:	���Z�=�����a�c��E}����=����U��h�0�C��=�?F<�4�E�D=�}T���e�H�򼦇%>h
>���=8�T>E<ü�cg���=��8:��9��"E>�P=>-���e�R=����(U��2>�a�=I	����Ѐ��wI��d��=��0=�̽3��=�8�ދ�="�)��k�<2�=
��=#0�=/��<����
>�!����#�>͸.�ԩM>ۺ��g�۽�w!��Dr<���j>�V�Rg�>�� =�w�=Φ�=��A>[=�}�$J��N���&b>.yۼWd���� ��E��B���,���F>r�E�@�=�ۨ=�ӽg훾8��2s;���=!�7�yI����U�+�Zzʽ��=9�b��Ւ<ωf<ڔ=k�E�U[���a@>/l\���>j����?�T��:T��]�d<Q!-��8=�2>�u=kN��ُt�_>0JĽ:XԽ�x�=01*���[��)ս�E=n>�=Q���:���d�=nO��X�<���:;+�=�z�=�=]��lk�:��=��ᙼ����P����!�GuK:������>=#�	=>�=�=�@���>��<_��b*?>�!���>s��=^���r#I={���8��=�b=hP� �1�������9>��=��H>w=яC>Ǩ�V����	�{�뽛���5/B>I_��㫽zȏ�,�p�'\1��5,��_%>�ӽ���Y���M5<cl׽@�5��x�<�/�������ڽ��=��=kO���>���"�J;<�k=3u����E�a�F�<�/�=�"�����6̼ũ�;ù�=�E>?�9���F�N���^ĽN�O�d�>ͫ>�m�IN���qO=h�⽰�<��=�P(���T���E����6���>�5^=�h�V��=�����C����=��>7<ъ�=㶽�ܗ���<�}@�^=�>��˼�BJ���|=zw�=�E���<<#�<J֜�  %����F�y���>x��J����p���Ⱦ,�� @>��=��D>�TU�8z?�>Q�=C�=��=�"&;�쿽�l>߹6���=W�L�=��ļk�=���=%���0�=���=j�x��T���V�f\��Huƾ��=A��=���&><x��f�=���<�PI��
���QL>�U�=5���X���򯬽��>`v=�'��)s�>����&ཪ��<�5ݽ]�i>���O&=q��]�5r���>6�p�r �J��=Q�8��8q��\<�
J�+��;���R�ǣ��m��#�>>~�/�8t��uA�=��<�{:	 h���;��v�V�>�$½��	=3I�=���D�����؏=�]�HY�<K=��y���>��y�"���>
�Z<i�0�3T[>�w�7N=�/6���� �j�m8�<͡y��Ŀ��/��ڃ<�T�=��⽚f�9BC=��=|�=�����*>�C���$=i�=��,�%2i��1�ZkS�C�����MN>�5=�J��ޞ<����L<��C���H��>�å���M=��!>ι��*>�>�$�=����?��=���������=x<��Y�=��罍1�3%��Y�I>����z�B��o>��p�=�n;��R�����[��v�ͽ{�=c��=S=S��������@�Gd��]���ڽ��=9�>׸����|����=_=@o��j>��Ž�)=�6>Ɨ=i塽5 �=���=ϲ۽\<�>:���0V����i� �v����]'!>���b�>�%T>��g��Y}=��t��|>�}Y�H�_>jAۻD�</S>=��<MM�=�Y��Dm�>���=�&�=L�>���>{��|�:�
�= 'м�n���lg=�ٍ�b;�<���=E�>6첼��0�W�Z>��G=[=�=�C�>�)�=��8��T9>Uʀ>��@�f�>I��UZ�hнBp<��I��süsr>���)\`=����Ƭ,�_�=�qT>[�(>�=�Y>��ǽ
:�f��[� ��1�;6kw���;�
 >��)��H̽oT��*�=�d�>��<>�>�=����K�� q+������.n���Z=��=u]�'��=L�,��0�=�Q�=�3;��4�<�y���
��z ����<���T= �>������=�Wj==C_�*/ʼk�9;[�C>��{��f�=��>���W�
>m�v��?O=��K=FH���>S*�=���%%��`E���V>���!��3�ռg���O�=|�E<,y?=�9�B`#�$��=O=/�=�V���d=��>ZU
�وw>�l<��e�����L]�=��=c-=P��<����=���=f�3>�ϺA�>�z$�BG����i�L��$��K>G��=\��=3Y_� y{>m��=��~�CSA�v�����S���>'sP�j�>��=i�<I�'=��W��C&<,=�
->��ʼ���<����%��=�ua���=iʈ�3��=��<t	����
�h�2��<;� =dܽ��=�,3=�����e��u�=ſ��Dy��w�=dX]��cL��r>��� j>'��磽7� >
�@�R�����h>"���S�q	νc�>n��X�@>�@(>;�c�F��=I�w�k=ּ���5����<�">�Y���=�ٶ=���<¦�`���%���_�=�#>1�=_���tJƼt�=)P�u5�=���=��>�%|�����˂�=j;�==�<I7�/�>qe+>�#����=6y2��0�����п1�#M'�O �����?l=Ry
��1>>�yȾ��=�����=O����2�)�=��%=^��RHI�Q���9-��޲�>�L=�� >]�ʼP2��[�>N>൑>Ѕ ��>'��Zi=3Q��.��=�Ć���k�%��=�_���w�=8�A=w:�Ȕ<�VԼ�������>"]�*bZ���<P��Zύ>g�x��w�=�Ś=�]�=&�"�X��(}�/s�PU������V<Q���d�������v˼�ʳ�� O>d
̻_�J�~����=븇��^>��gA>;wѽ~s>��U=��:,�6�2��\>{K&>�!ʽÂ�= ��=��j��!�=/�K=g��=!�=�|�I�ڼ��*��)#>�u!�,�A��p<��нN;>m�ӽ�w��<��l=�/�=*��Lk�Zs߽��;s�=��G>1{��HA��ay��i	:J��<�wE����O��=LUe>�Ԃ=W>�.0<<:.��2��ƿ>�^���� �Ŗ=Û��\�=�N�gb��5�K<�-����<W�F��^f��_���$�F�<=`��b����<�t=���=�R�<R|X��K�Cy�Y>=�]Ƚ$�ｦ���FV��S=��=ɔ�=�]>9^8��)�����R����=��=ֺ-=Aؽ��=R>>ߧ��=���k�3�����V�%��t���t>�O�@��.�>|5<l�K�ծ��0:;�P��=�8>`�ͽh1J=�c>��8=��o�M�
=i:�=pȼ=�)�jP�=�U����=�-U�悻�<�a>�p(g=�J<b =F>>�p�=AȽ�P�=�Z>@bb�cLK=M>QYżs�ɽO����=��=g>�{>�>��=>���=����w?�$�G��� D��e�����n�=��h��$��-�|>!8|=�g>���=6>�Z�bA�=�Bf���ѽ<�������;�=%b���V�=���d����D�Z����>�Y��%>��=t?�P[�=oyν���<���<�p��Q���r������� �n���A����W���)-�K�7=�>l߼`�==���<`��3w=�����t�u��u�=�.��>�=;�>�2��(x>u�)=��;���(�=|e�ZyJ�.�K����X/�b�����Y����ȣ�J�<Y��=�K�<Մ�>h>���v��>�;� �����<�J�U�n�vsE>[p�=c�h>�ǝ�Ҟ�=���=�p�a������;]����>�n*��1<V�V��ֽX�R=���U~5<Ri��C���}��ת>{��<9,�=,w�=����	G;�/7�&y�=B�=�����<F]1�P�７O	�%h<��B=�:V�X^>�l��;X��=V
��t�l<'w����8�%2ܼ��ɼ`���m2=��%��Gǽ��7��I�<�Z>����g'��+Y�g,%<��s�������ܽ��r>۞�<((�;V)����]1_�37��tq=��T=Kg&>�~?=_�=�4�=ʿ�=⟄�.(|�	⪽+(b������k;J�>�w�=��D��Z�; �=ʌ��p��=�L=����֣���T>��`>])h�lt��S��=�M<�Ǡ�ARr�@"]>�x�����r�_=0>�=�d.=�P��"=�p�<Y��='R��f}�=�]�zcY�{\H�8�*�+>�Ж���\N=�� �w�9=rD�>#���5�u�k���a�= ܬ�+�	>#㑾�1^> �}�3=j����n���F:��|���<WKI��!�aT�9-*��#f�8"�>+��9����~ܽ��=�h>��@=�/���
�<�,<�`(>���:g2�=XGV�S.H>����w���<r���Qg<����8c�>L�D�(��V����4=�sN�dy,>ג�=fד>�c������A��)��=P��=�b�>x�mM�;��>�@�<q81��2%>TuA�����m�<ƛ:=�r=W�=�΋��9>�a =Q��=<E��=w�	�g�>�����`��rW2>�}����t�׽fa><�_�gA�=�8'�������;�{�<�#>ԃV��|[>��:�l��<�[�>�j:>�z@��P������_>'��=v���&=
����p �� �='>�$=�⯽��<w=>9Z��Z�ӝG=iQ�<�e�<���=R�~>��	�fA�8��=�9b>=���.�=��=��>��>R��Z���Ad��Є<j�>h޲�2}.�{@S<��;H�,=N�>z�=	̓��a��hPL=��]�F����	>���=��/<k�q�����Z�;z��=�E"�Q�>j��= *�<�g���;>���=A+r=<���p�F=���=�<@=�4>��F=��xd=��i�=�C�=S4�=�A	��!����[@����p���<�g���$��z�@m���i�;Na =�U�=�垼EP�=n#��՛� �˻�a�=�*���^(=e����:4<ý��U=Ɯs=P��>\jY�iT==�<ߛ���U�"�=eފ���v��%�׏��(/=fb4���>o<j=\���*��<	S��gV=kӪ;ʹ�=sB�hY��a<��*s�5$9�/��=�����<�a�<���-s4<_z�=Gڼq��=@ս�V���Ȉ�2:�<�=c˓����=I�ԛ��ٻ=Uǘ��2ؼ=��N�=���m��=��;�O]<�ؽ>w����13������vH<��*>�t���P�=�u>l�P<J;��j=T�Ի��N>�� ��Y	>/zj=G�<%�P=U>�`�<)�?�l*��~Q����=�C��t�<�l����=��d�s��S
�&<�=�`R��A=�#м�=������Y�s�H�;�~>��{=��>���=�F>;���7��<~OS��� >D���=�=/��<&V>1�;)ȹ�#=�t=�9�=��Y=\�!�����`��:Zὕ��=���#�=�<>z}�;��=���<s�����>Yc����=*-�=�ZѾ�#P���J>���ǒ�>5�Z>Muн?�e>�j���;����D���ۻ��ɣ�o��<��=�L�-3Y>8>�ؽ(��<9p}>�B=���=t�==�|��8<0�/>� Y���I5�T<>���=��=�Wk��B%�Hh����hI�\b���ͽ�'<E
��� �<�	��`�78������n3=�S>�7�;�>�<Of[�X�>��K�*��\���>
|��.��C>ĉ*;��n�:��<ouB8����V� ��X����=�(=_�=��>�WS>����F*=��t>���>!��<ٕ=��S�=�
��q�=:�X=ư�=�d�>�x	>R�F��x�=%�z�	E>�`���x=���<��w�h��ü��vƙ�~��=�WY=�'T>�ᙾY`���_t>�V=�v��g!>PǍ��&l�nC~=�43����=.4">כ=���=��K<��1�!�s�g�)$!���=ۓ��*�=D�>>�@���b���=*�d>6�@=�f==�P>;k>�&
<�a������a`�;8�=4Ϝ�8�>
�>��T=Y�7�8(�<Bqf=+��<�ʢ=
@�<�>cAp=�ӽм?q�=�;;�Q���m���>��
>���f�� ~p;�ޛ=�i��W{�:9h��w񽇀��*#�'�S>2X>������ռ*N=C2"��������<>�{���m���9���!���T>�cԽ��8=���&�ὑ�W��h%>��>��D���|>Wa�<"*���0>&,�=�b�=;��#�K=X �b���ݽ��J�\�=(=�(�=��+���Y��y>�~�=&R=�ʰ�5��=k��=l�=�!��HK�I��=��<���=fTi���X>ۜk�!]>*+Z>Έ=��n<��x=v�=�ɾ�,$��쏽('>�M>
j��
��Y�*�$m^������c��	+>�3/�1�y=�r��b��       9^U?�=i?-�?d�v?��?�~�?y��?��=?>�V?��?�Wt?R�?�Mk?@��?Y��?/cW?�q�?��p?l�X?��z?       ���>��>�.�> ��>'r�>�3�>`�G>�[i>F�>��T>2��>�;�>���>�
x>,��>�1�>%~�>���>���>��>       �?�b�1>>���>S =>�=>j�����=��n�!�&E�=��=��>�蚾�i���M<�����N>��3>�|R>      ��)�T޴���ѼvoF<T(�M��e+���Ͼ<C->�H���D>�=���=B�=f^�=*_Ļ��ʾ+c�M��=D5�<��~>M�D���=�#ʽO7�So�=��E���P�����^�ɼÛ����Q~>8=�㒽/��{v]�0T�n$��l�=��P��D]>�J�>�Э<�Vc�����ߋ�;��1�V�F�b�Ϻ�P >
�=Jm>��]�gM	�SW���]������ ����=M��=s<�=�o��ށ��v�<vh�<]a���ԳR�l<=fvJ����=�[|���>n�6�����k�<T�=�ҭ�ˏ?����=oݖ;���C�e�L��MN��`>Q���}��!@=�mx�t�7�s�>�-���=�1>�Kp��C�=��=��,�_r��W�=�_��h&K�C�����>� �=	Y<���=�k������y�k����$	>��Ƚ�:q�[>�9�<����=G)�������<�<��U�x,�<������@sr=m�>L��mQ;��>�i�� yb���9eI��.�޽���=���<Ĕ�<*h�-d=8,���g<�䫽��=�9�={��Զн�����7����>":�=/]l�ϝ�=�-`�pg����=�����ϼ- ��)����~^�Q���)T=�Ȣ�Ub�=�c���.�E�\>\��D�p�%\�<q᡹88X�]�	>0'������c�Ľ�b >�w4�����Q�1�+����=7i�<2��W��=�\�,(��X�� ��<���Ok�~HZ�5��{���Rl�=��Q�������<=�&>:`�<;�=)��͇i>Aw9=�$���)�<��-=��û�p�B�>��=�Cs>��ռ�'D��[+>��=ϡϽ[\=6 .�����m����*7>=/=I��N̻^.
�]Ľ~D�=JG�m��=�"��4��"��8#��������低^K=m�>�j�����Kܽ��d�X�h�͖>>�����=��>*�𽟻н��i;��޾8�]�'U�=��=��ļ9�=�����iz��k�Hq����<3�u=	�;�+ν�=9�G=ި��F���@�����͞�=�]z=��Ž�� =��H=�8==~6�<	�!����W�N=����<ۢ�_a-��ɮ���=Zw�=���>;�<���f�3&j>f�/>����3��xX-��"�������>E��;I�=?'=^���s�I=�O�ۊi����>�B���Љ=�ٽZ�7!����N>1@���7g�<~����o�-X���y��$��<�=)>U<g����nH�>��_��=X�>^�H>�>�b`=N�"�RIZ��Z>��x=�7ž$�ٽ�|E���=S���R=ܖ3����B�L�"��sn=
 (�ҁW=�O�=�5u�.��<���w��=��վ�d�<���Z��{o]�|�>���;LF���A>7������=�;f=�����ϳ=5�h�Yϓ�c���gM�=���4��ir��8>��
����uI>�R�q�%�zm߽�N�<A{ѽ����v=���=��=��C���<cw=�>م0���^��.�O=J	+>$���3�w
�<�{�=���T�<�ؼ��=߾��>��=Jπ���S<��=��̽�gq=�Q��sѳ�Y,�;�ն���v��L�R����Q=�5���Ž�#ͽ�)��`ܽ'��x�>u0��.@>I�=ގ��`J@�mѽ
25� ��=|�=7�}��&�<3(��Ҧ���t=��n=�,��Ϡ=���j=Տ����=C���SZ8��)����'��0.>�l�3�d�:�,�H�U>k�<(ED��>�$���u����BWּ����~=�<�/�`�=a�=ʏ�1+c=t�+�ˎ��O=��Y�t��=�4">U�~�1�w�ʀ����=�v3���M=�
=��Ǽ4`��׻���%���,>Kt=��=�u<�ؼ���=܌=�gZ�|�����߃:�q�>�zg�[p�=1�,>�>��G.��k �Mg6��5=)��=9�]��9p�.�>=����:>�?q���]��q,��t��\���>+M��l�>W��1����΢��@%���̼���=�����5۽�(=J���       ��;9M;�p�;W�;9g@;D;�t�;��<.�<V��;�k;��W<˳;��;R\H;�<��4;|��;�Mu;�8 ;       �]             �h��̽5���.���( b��0���r�Aw[�ha߾vJB�k���Z�t�F�0����%��9����;u�dؒ�       T�ݽ�N �gۜ<�&U�'@>ς��	o=��ƽ�)��'�l�;�B=�c��K>�a�=�?�=�_�<�~=��=^�[�       �=X<�>\i�=5$W<�^>�o�=m�=[+>�	�=�L�=��2>�b�4�b=�t�=ȝ=�-�=���=�;�f�=�_K>       �6��k
&?���r2���s�])����>�k�+z�����\}��,��8kϾ��>h���+���t��u���TH>���;       �]             %2�=oRv>a�ȼ��>R,>�&��!?���>�#{=�g��^d<��>vB-�O\�=���;?y=���;8��[�:�\��=��=�z�;�t=���%��E��ɫ`��J��	E�Gz>Ǜ�1'���Ѽ'bW<Pǽ�.>>k���5�ξ~%R>�5�=W+��&	��t>2 >�p�=>�
=C]Y�C0N��"齤L�;`'1>v��=�H�=_�����=���=P0>>G޽�m=17�;(��w=qK�=��!>n��>c�5�f��=g��;﵀�[i|=s��=2�\>�޾S�?����+�2�T�`���5��\�=5�]��bw���e��R�=p��=��X>�>Vխ�u�u<0}˼{0�=��=Ҏ��W��<�'�=�}`�ֲ>c�,��<  �����=7s���A>i�B>���w�=�Ʌ�?�=��G=���<a��<���,�>��=(d�=��ǽ%�#L �6,�=Ԏ@>�	<w�=š�<�Y�=�?:�]E��!�
>�Y��/�(=�>g����V>���<��=��=��	>�v>�	�=cW��#����>�rԽ��T=W�<�4���ٽ(�N;����B�=�r =�ا=kS̾��	>�`!>0�Y��A>*�=&�'>݄��=\�">b�<�B>��l=ů;>�h���	=	���$[l>0+��x&P�3m�=���=�T=��=;������F_:r^ >QhI=Õ�=#�����N<Ӿ�j�:>;���!���s�<�n>�~�=�D=�4=K�;�)�.���(�M�>ѳʽ�Ө>�:�=vܴ=	1>���5��=V�d=𾘺Z�ż�̤=�/>qO��X)>�w��9u>":��j=�
�wT8<�K=�}R>�����*=��ؼ9��Q�O=[�ؽ�	>��=t��=�Ԧ�Z�>0�=i�,>O59=�T��� >�Rt=�{�=�i=yU�=TR�=u��O�'��qJ>�w�k�6=����� L=�/�������0"n<�s���%]>��`>�"=�o�=gJ�=@��E>�_"�DƯ�`��:�_8>���s��<y=�=�^S>>bֽ���=5������*�w=��~�'>5���<fi��Zk>q�ὁ�C>��6�����;�b=l^;_�g=N>�U=���;U�T�;��w�Z����>�)ֽ��1��FؼfU�<Ā]=X�ĽlI�����;۔�=��7���z��=8�B>T����= !_>#��=�o�=7?�u�=�{'�"t��n>��=FU,����=�m�=��=���S�=�&_=�9<ǑB>�4(>T�<>��>0>�]=L~;���=�����=(~��!);{�=%�=jȔ;5�?>��&��E>n��=i9���)>��M�e��=h�=4��=F�Z=8�s>��y=�w��<,>U=���=��=?��s��>,K�=��=��H<��1��0=�����ϴ��5#>�T�=�c->�ջ!�����,��^�=)��=�(�=�:= D�?cۼ���=oq�=! �=��=�S�<��W������	� 8�́���f<�.�=$��=?�h>�d=-�����ʼ2{s>$ �J��>����Qͼ�ر�Ȏ*=Yܪ��	����<�
d>�C=|4����>r��=���=�#�<Z' ���>�o6&�*E�<å�=�����0>�É9�>ɻ�2�=�.�~U=��ͽ�>�*��3�=��
>�x�=ɝ$=c�E=��=xۙ�W��=�"Q>Rd=Tn���s.��-��1+=�}">!U<K|��OԽʦ�=c	=�A�=�)�=r�>�������=��^=Y��=Z��=3>yl�==ȏ�� 	>�Z)���>ʓ����=��=!2�<����C�<a��=��	^�� +�O��;3Fw���6A>�&/���>�5��������!=j�A��ֻ�K/>5�>A>�T
�>*�>�E�=���
j�Ğ�;�#=���:*о��\=2�>�#>-�^=X>��>���>�?=	>������t> %�=k�V�u�=Xx��Y���>�½�=9�_=�Գ���=D�1=�f�=���=Y_>�ݍ=�:�H�=ۤ��#�R=]`�=&�>wY�=6]�=�����t;��<���="4>@���U>�(��3#> �ؽ��=t/�=Q>�拼'5ͽ_F��e�������8Q����;��=�w>I?�<���=Z	!��ľ=ITG>��=��C=� >34��F�>=�����R;P��=Ж��=M>��=HG�<[u~=��=g����e�<�p
=A7�љ=�j9��!<)/�=��̽3�H<�ь>���;@>�4E��p^>�$�=2�j>�����<��|���~=_T�^�9=���;��v>�:��� >|r�rr�=]8�=]���Eoj��-�����={;=�7>y�Q>�~�<��>��ؽ��>N6.��o<��>�m<u)�p=>�,��a�=<�:>`->�l<i��+U=�Ԭ����=�,��Q�=��
��E>¥��9,>p���&���Q=��%;�=	����(�< 8>�8ٻ��>{I��/�>\�F=���=(�཯n.��&���֟$<�':�!�>�v�=S��<>�>��>,Ci=B H<�� �V\�<V$<>���96>f�=Z�c>�(Ծ���>� b=[�"J�����=3R���e���<�%>�>�<��>�8νX>���;��C<��b=ꬴ���=��>7,�=P��<��=".>��|�%��=j�>�>^�<�-����2��I>����ꍖ��Mڼ+�=vW">��P
�=�P=���h=S���t�=�J�h�N�T=�pF��@�>���"��=>+;>c=PSI��x˼n�1=�žP��<+2� R=^n�={��=d�=N�7>7x�=�,�=(��=GS�<Xզ�b,�­����>V]*��(�=2��o>��R���<����1�D���=���=�CO��>B7���G<���<�u�=
��� �=�'���=�U����o>�3���7��q=V� ���>� O=�����r>��ݽN�v>���ԋ�=��=�	-;c��=� <>����^>��m� 2>�7�=�s�=�E�=��=o>bɽ6)>nA<_>W黽���=�����;'�>R"�=�ş=4=by=[ $=��K=��<*�X=�Ӣ��;�^	ڼ�2�<�ħ�.X޽�н�஼O�����m���]~�}^=(������2[��U̼�׽3刽�X��ݫ�b}=w߽�Y�'��Ѹ�)�h=�t���b��;�!=��$=�H�ֽ(ND<����~����B� ����rʽˏ�����ǟ���O��V)x=�[��y˼B��<ŵ۽jfܽ��M=S+������.=:R��
'�5h=������<���=���m���="�۽��<K�=�1^�����Q䚽0�~���./=�m5=�Y�.3=�&1<�y*�N��1 =Qf�;�rU>�	L>D�3=��>���=��g�E�0>Xd�<�I	���)=!�W<!����!�>>a>wr����=3{>̀��=ֶ���ݎ>��=��0=**��9+>��?=�:v���=aӼ��A�Qu=�����6">9X��lK�>�������>d�>Z�ڽ1t<eǽ_Ȝ��09���>�.S=%m��`#=�)"�c�u>��="I�=e�=��<T��=���<���=&ݡ=1�ӽ�%�;�⽩�߼!���'��E�=G�<�T>$%��U��<���^�;,f���{�>s�b>@��<)c>�=�42=j�;�>�wg�_����N>�.m>��νl�Z;��u�f�2�9=�<�=D�K�7�sg�<!ϼH�>�ށ� >Ds�~O�<���]ʘ=�D�w��>�O�=0C�h�=`�P>u��;���A�>;/�<:��=.<%��<��L��!>���= �<��<����X�=V߼5�(�B0����R�}+ܻ�j��丽�6��@H>n:�=�=�Ɖ;|�=��<>�!�=Ký�a=;��<��;=$��<g=���=ʿW�*%=�E$���I��<�@����>��u�U�=���=3>�>���=Ne�<��>pLͼ�B��tl<F�(=U���G���@J��_��[*>�cü�;><��=y1�:��;��I>,� �%>9a���:,>Y�(;� >/#�=��>��ԽǙy=�=i��<��~�C3���k̽IJ=J��5>3�T���,>��i��3>������=�W�=�����<��L��� �<Z��6�4>+��=��X>�5z���c>5Վ<ݨ5>Ԃ�=3�>0����{��~��4=�FA=�#`>�t���=f��=� <%�q;��==u:>�g=aN�<�pY=��(��1]>��6��j ٽ��=8�b=��:=�$c>�#>A-t>�L��bC>/�����X��<{�<%�(>.t>���=t�=�z>��}=���=���<���=���=���=1q�K,��{�/>����ޱ>=��=|�>>7��&(>�e���k=�b�<��>ԓE=C� >�1;�wB�� >��=>���;�]�<uD�=�Ǐ���= ��#9������
��L�=#y�=7�>�����B=�D�fA>�w�����=ま���=�	N=Y��=�>�چ=;��=�V1����=�3�=|b> Z����=%N>g��l���y�{=�0>�t�-�A> z>�m���f�����-�4n<���=y>��>!�[=��=�)�=DW�k�u<Z:��}�=��;��="VC>h)�=#�a=�c� �<��>�o>�>��>n��y6&>��=�X=�>T�(s�=_+Ž�Ľ�@>�g�=����� ���ڝ��$�=�-�=�ΰ=��=�!��\�<J�ͺ	4�1���k/>�.,>��2=(�=�c �̥�>ˇ=b��=NQ<LT>dh���~=�b�=0
ѽ�a �=]k=�!�=#p�=��=����˽���.��u��=�R�=��L>G"B=00�<0�`=��P>��[��5>�� >�O�=.{P=H��<��:���=`��H��=X���@*s��2o�]J�=l�<��>	���3�>ZAQ�1A���_��۠�<4wȽ5�=>���u��n�V>�|ɽ�Ք<���=7O�=���=5[���>��q�n��>��<����8�=�f#=���Fߘ;��ھ;���d���'�x��=�6�=��u=��<�{3�‏����;	;>��=@��=G���ޒ=�S�=��R�5=Eֽg����<����#��=��=�>��@=�����p��S�=||�=FD=Ͼ��cʉ���>���r>��A>F��4-P<ߔ����d���5�.��<�ݵ=��d={�;=��">�`�=HHʽ[/�R��>���=?�<����7����4=��=ͭ�=���>r�=���<d�ڽr�=��w>�.���&�=v=��>�ߣ=)8$���>��=`ԽeB�x�<��	�(��9���̽j��>�|Q��&����ͼ\�������ʽ�-A=]�=x�ý�PA������z0>��R���M�B͇=`f=�d<����̿�=����;{��=_�f��UD�_����L>=��=�J�G���m�=�V�<�g�=�*�k=*>��o�dH>�_�E�	>�>χ�<鉒<��5=�V�x�T= O<��=���O�>T��ɘi>8�}����=Y>��&�Ѝ�ے=�M�>��R=���=�������<����NL<�?9>0>�\�=��>O.>>���=/g9��!>m�e;Vt���0�.��=�V>��B>��{=@��ｚ>���g$���m�����߽[���.H<=w�^>�=��2=�!>� u>���������>�l>I��� �������=\2�$�->�Ç���f�S�h�rF�=/(>���:��۽��O<��=�0�=��E>k=�< _>�3�>�q=$C=�L>�=�E�=�);��=?]`=�ȼu~�=?�B>�1=Z5(>�6>�y�=n�G��?K>���/�=�f�<6��=�Y<��ϽѺ��i�;)R��3>(&G���>����t�>���;�wH��Q�=�UN��#+���q=+6H�Ն=掛�SB>;>د�>�~�>��+<�M���5ƽX5H�%Q��^��;���=fn>^z�;�?2�G�>���<�X��
�Z�e]<�~�=KĎ=�G�<�h�<��<X�<�N�+�l�9T�Vx��ݗ�Տ4���=V������qN>F��=(�>h����>lV~=�1ʼx�d=H��=���=.�T=J��;���>s��=��{�}��=bB��q(7���>��d=Ҕ���-�=c�<�˃��e=5�C=�>SƽV;��r[��
�=/��;[�Ӽ_���T����<H��>fy�=&���ν�1D=�5.<L`�U9=]�=���=�2.>)+�=Lb�>�s>(�w:��={�h��A=�����=�+�=b���	dK�>��u!�=�+���=�PF=�'�<�2=z��:�@g��� ��a�=�b=4d-��HҽUd=,D��K��Ji�=�M�<�巽J�����=5|���t>AqT;��>=�N=m����ٖ�m4#����� S>���=��=?y����A=��%>Rc9>�Ͼ�'x�=S��X�*>��ڽ�L>�������sú�>O*#��d&>4_���>�S<�k�=.o>�~M>Ӱ�<�J�>t%=��u�)�9���=�>����<�ʷ��.�=9��c�=	>�WD>��=�u9�M��=���\T�q��=�`�=�s+>Tsj>�7�=y"��ľ>3｣�\>B�>;:�=�J�=�S6;���a�>���=V�潷�b>W�4<Մ�C*�����=e��b���9p>�B�=a��>���=0�9>Pٌ���>�n��.�=��=���'���@x
�R0>y��=�Ȳ>��.���=MJ/=����G������w����
��{~=�	�me:>�$�=��'>&�����=_��=Vb�=LԒ��t�����>�7�=tz>�һ�h<q; >�ĉ=?\�=Aؽ�S��$������<S$�=��ٻ=����qR����;Y����=l��<��>�@�=F�S=v���r�?��n�=6Ɲ���6��1>V�q���u�����b�
>� ���.�2�7=���$�%�.9��u=)��=J�#<�͘=��=�o{>����(��#>3�p=7�=l��$St�nO���e�<0�+>��>:ʽ	G>�l�>���=����H�� ���W�L�;�8�3���%=X������=�E>R=l�<��>N��=Ud���w]=�픽(*R���<���=�s=��>�}D�+�/�8]>��>	�>z�<���y�>�q�=�>�-=@�"�uDZ= ҙ�A^<��>Ȧ=EP >I�j�	/�=i=s�}A�F�r=L'>qGE>Zq:=�[o���=�;�=r��=\Wq=h)�=���=�I>/��=���Xs����g=P���I�=�L>�Ig��=(��`b� U��=%����h���G�=E��;?2���>qT	>3ׇ=&�>�ge���%>��=�=Em'����==p�=8k/=�	>ɫ>Ck��u�:>�d�=��=J�;���=�"���>����fk�g벼�	�=��=���=�U7>���hӽ�`(>i�='vM=~XW��>(1���7>	'�=^�>ܜ=j���;>縼vAq=���U��
=h�v��M1>�t0���>�C���#>!���j��<E�'=�Y>?�,=5j=���� ʽH?>��t;گ>@=;���=U�|�ć�<�>br>�`=�v�����=�p4>m��>��<��=s����)=V��=�A��U���l�#�>���0�?=D$"���&>%��=�A�=�E��_@)>~�ܽ��=5�l=���=l�<Y=�=:x��=�>�pѽã�=9��=t,�=�{w>����� >-���uU�=�(=��gH>��=�=�\�2_�=������~�ؽ��hD�׳=���k=�;��qP]��}�<*�S;�N>N�N=w�5>*�ͼq��=%�<�c$�  �=Dl��*=R>>�p,=�.-=
�=�I�=R�>Ϫ���]�=r���=Qv=eۏ=�*��P�=���=fܗ�E�r�3�ɽ��̼JQV�0��=/��<�>>n��=��>�{>���=�S���|>�=a�U��,���ӽ�����E���h`=E$>��=��1=u�6>Ӱ=�	>`�B>#����4D<�>=�|�="�ʼB6O>L�Z=&�<�PG=G|f>�F��=�8>�u�<��?=爂�_0t;�Cb>�/�:�3ѽ5|�C�D<����S���a<>��=��=�﫼)�(����/A9<Fs��M�=�i=>%�=�� ���7���<��R<��2<�� =������<Z��=��<1o=��>Av7���>N�>������<�8�;�g>�">����+�=vW�=\8λ���=��<��<>o+�j-1>:,��ٽç�=C��߂�=��}=	^����6>z��=^��=��y>�e*>-~��Cg=��6���<��@���z���
q>`v>�*>��=�~;;O��:�?�=×������:&���S����t�>N��=#O>D��=+�?=R���<��;�ն=�~]���Z�1��8��=���<�Q��;�+��=Ӏ">��Kf缵jb=�Z>�(>Oҩ��M��Q���^Ş=��9��*�<�Ֆ��;�P�ͽrt=E\�=K!B�(�=[;	>Òh>!}�=��=�|�=]l+>mCd�l0�;H8P=m�ž��U���޽:��=�u���"<���cD%>B(�����="Dc=����q�?�U��<�����"�=ց����@=:��='z�<��H�Cd='iE��9@<�K�=X[���
�<�n>�4>=}A�=�v�޷/>�����5>����7W>�釾 �=x�� �=��=u��<s��=I����S�F	T=j����bU>�8��W���&�%�>����Q���Nx<���_�۽�̥=�V�4k>+�>��=�)U>�K���w=bF���?��Y�;mʱ=��5�cmx��	>[�$�r��x�=�|.�����O]�=��5��>MBl<�ȼm�@�m0����ǼDʃ���>�-���>R=��ս���=j>S>���=p���-�=����Yq>O�������0��/�>=���ݎ>�S�=^��=z#�=��������W�*3������#s�G�=�۶�z�	>��;@���%�Q���> w/��X�=��b��v=��9�Uk�?3�=w�����=�Z�=n�*�=�j�=�L�=�\y=1=R;I=���=���"ƽ���=_%>��=õ'>r#�= W˻U�3����=8�O��<^=1��:�}>l2��r�	������%�<�+��S�:P�8=�^_=�f�>�=8 �<.��=�e=}�=�&*>����`L���X9��+=,f�=,�=��=��5>,C˽P�D>q`<V>a�-�>_v����=���<�pC>��=��>�N�=?�(��q�;��8>t�Wq<���QU>�dq�Fx>���=��W>���=�0R����ĵ�=U�4>�#>c�)��o�8��f='�+=�,F>�e�����=ko�19�<����k>��b���g(�mT=�>x�ý�a#=ݩ������\�;��<.@�;�1>5y1>�v��r�>��=>?��=�#�1f,=��M�惵��*�Q����->�8N�'�>P՗=�g�=P�>삽<�>2>N_����=�9�<��I>����4�=�>f >6b>��ҽ��`=^a彗
�<�f��^<>r,�<6q>N0� ����4�ا\>����+5<,>f�=������>;^)���=_&�����C��-�
��ĽSR=$ki=�q=����~��CF>M��=���=���~��;�a���->�V>i�>[!�=����^P�=�_|����=����=��̽b��<i���ʝ>Z:|��s�F>��%=��=�A�=�}�=^�>��A>�pI>�S<ˊ�8�)�"��D���<a�F�b@=�R>��=f�s>1�E�K��<�qٽ��߼�Kx=;,���=1
��8	=���Iy>a�U���>��潘�3��a%����=�ǽS�=�	9�Q�7�l��8�>(�<�		>m��=���K�=�Y�=���=���=]tQ:�"E���D�>����oc>;
����+=���w��������?�PO'�.[ݽ��l��y���8�=�h��&�=���<��=�>O���i���;#����N@�Γ>cu%>�W��X�Q>�(-�{�%>� >@�=qΤ=Zd���/�<��ͽ6h��*�H�[^�,M�4q>��;TfF>˃�n]J>4�%�P ��3�=�}{���y<.���9�P�����k>Avn���K<j�=�g=�y�>MLмW%�iǽ=���ZTν�T�DM�=N�\�6� ��=�=Zx��`>�B���>Z�=��=�1n�`��D);�%������<h�>��.�͏��LI�O%*>҆<Un=�d}<< �=(/=�/�;CVֽ�� �K�=��>4U�=�>�cڼ̎�=��>�d��>�XL>dd��sY�>����4½�vҾ10�=�tt��('>�� >���=NEK>�\�T����?�}]�=��9���+��ǳ=	=�=ڇ ��I0=)�@=<j�=@d�=d�=m�>��>>~��=�f>��d��J�m�&�G�=�đ=T��=�k%<��=�.��>B�-��0T>�[���`={�&��<�>Q�>L��B��=Q��<]��N�=��<�̾=uR8��3� `T=Q��=E�7>�\?��w>k�<�z�=o��T���f�=t�
>��=��>���=��>��5�&���*�X�Y;X=%�;=;�޼��g=ʼ���mQ>���;�k�>��=�Z�>P��<�Y�=ka�=Lx�=��9;{ ��'��"g��8�#=.�9��V8�:1����>�v=@~=s0.=,4���~�<IB>�M���f���\l��D�<M�U����=�ݽ̰�=K�	>-;���'=��#=��>�T��<�\ҽ~�=���<c$�<�Uͼǃ�=N���kT�=*���U1={�.=�g�ln��I�<�N�86)�?c��X�|>�׋:���<-t��(��>�5/�D�k=���=��b<�-=hr�=`ԭ�P�>���<���=XYk��M=\@�=F8�DP�=���=���=*w.>�#�=�%R>}���Kt�>��G����=��5���:��k��Ix=�=��s<�=�=�PL>�;ǟ��A�=Ѱ>���=�����r�=6��9��َ?�L��=�m=�ݼH���bq<�qP=o�m��sK>�(>U~s=�ׁ=u�=�dZ�4��:��s�gN}==V��Џ�E��=5�=p󩽎K>d�*<��x���üg6D�_*k�E��p��
 �ݒ�=5����=³�=��,>��>R0����s=��?��0�=t_5�f�>'ͯ=���}���� >���=@����_=2����lU=r���V���\ϼCIH=l��=C%�r|>����YE��U`��Xc>.�ҽ�D>�r�=��g�ۓټ[٧��ٽ��:>3*>#M8>�#�=��p<��">�ȹ�n*/>��>��t=�sr��#>��&>r9��,Խ�4>��
��H�=)�s=���_|�ޞ���� >ߨ#>��"��N>���>����ƽb:Q=�֩���=6���H�=��ʼK�?>�`0>s�=��C>T{��hS�=���=��=��<Ǌ˽I��=ݦ��B����=z<NE�;�<�6��ycнp�Ｍ]P>ݭ=�z�=y�<��=�iս�E�=���	�G�{w�=m֕�I��<Ә�=>J⽞�>�<f>�_�=�=8�%>02���2<���=�82>>�t=yύ>V��Dj��k���i'>��Խ��>�w�GA!���>?_>�9�=�>=�_;��L"���?>ҲN=��;�7,,=�$�=ʏ]����=�,���$>��y��d��Yy��r��p���k#��gW�}K>!�=#5>�t8��2F>8+���(ػ.������^�=@��=��u=)Xüß1��f�x��r��>J��8=��E�1�ּ�<��`����-�=��;��=-����<�>���=�.>�=ǻ)�Nݽh/]���ѽ�;u�l=s
3>.t������>�=Y=�P=P�@���Y=���=�鴼[�r�>��=���3�=`9�=Q�<Dc�='b�
�<:�=�x]��A<���k%>��L=�X=W�=��x=����W��<9��<��o>m�C����;8a��	ս�YR��d>>��LV�=w�;�=�>��=k��= ܴ=E��7�R�]��� �<�����>�.�=�ʶ;��8=��?<�r>v�"=�3v=IL~��,�E�-�g"=�ޡ��:>��u[=(Q��<2�>��?=��>�'>S����P>W�D;\� ��=�g���+�Ġa=|��=��罅L����)�7��D,��EA>��X������=D>Oф>�j���o=}�5�{�=<�d��Ôu<��b>f>_=ˇ��@ğ>�d=I�=3�#��&�=��G�m��B��3�>�/=	{0>�A=�~�=�?�=3�>�|��+�=�wW��N�=���s\�==�i=�̼��=��<�_%>��u>��l���=�\<&��=+5���n<f;/���DkW��0<�X,�=r$e�-��!`�=d`N>�
�:/@c�è�=�+�=�`�=d�����=,t�=A��>�*��壽*�=
/Ͻ7�>g� >\d>�kl>@;0�Q>W���O>�L��,��{=Ѓ�<�_�1�=J�<,�=�>�j� ��+�<��=�ڨ���۽�^߽2��X�g���<%���ս_V��c�F=�4�s�g4�}��Iɽ��=�EϽ�,����½���<�=�9����U༒�z�*��Nҽ#���6��Ժ�[< =V����u=��=6�)�N=��2�k��I���᯽f�o=.Q�=pX�����<�؆<�-��Ж�n,=W������,D=I��<VH:��&��1��pse=(����ν'�Q=� ��߾�t1̽�����^���ŽN����M�q�޽�L����= p�������,�N!>�Ku�b;>���=ʥG=�4�;��>1�D��>ǁ׽��v>#
><H;�=�b���Ȼ�S�<���=�y�ڟ��[U���6=�׽���=6G�=�-�ܰ�=��0>�TN��X>�o�=�>��<�,�=�<v��>"�ս��S=<��=�f>���=g����T�=�oL=ȩ=ފѼ2E����?>W�	�&	�=|:Ƚӗ*>�Nf�σ�=�g�=�>��>͉��޻Z|)>��=�]jd<���=���KS�=:*��>�k����;b䠼�;z��=2j��F
>*\>��>ޙ�<�b1<n�>=+�=hߜ<H�4>�D������>>Z�����=`o8>���m���oC<�� >3�E>W��. +��Ɉ��2<i�l=Mf�=ն�=`���Jr=�:��?��z=>�9=Wm4���l���=%l�=
�C��Ȋ�߬ ��,������F>���=<�I׾.�<���=��=o�<ɺ�=� �=|���;,�Ǜ�=��@���t>��#s�<6��?
��Y2�=Z�bFV�� ����;K[̽3�	�[a;=�<�=�p�=v6�^̜=�#Լ&>�t�ۀ���`N<]�M=-�2>�b�=g]𾓰�5�>�(&���8'�V�=H90;�wb�M�����^ȹ��H}=���<��"=˽�3o�y;�o���Y�y2�"9������I�>=n�m=I'��ɝw�:��hHͽ�q=r~ʽ������0�����;��ȽQQ�=#�w�U=B~#�U����pɼF��E_=��^�]8�[�:��ν����W����=Nϣ�O>�Q����_; =��+���𽽱��)���{�7�D~�<)�f=���zd�&��<����A���8��[�n�G/;�5�=�{�<���j�$� L�;@<��c�&`���<>ȡ��������k�G<��=�=�i4�=��j�ܼ>��%r�=�q1;,�5>u���0=#�=���B�<=>�Nr�x���I��=�\J>��a���=^f+�<�=�V=�q��=P�>��U�+ɀ=t��9�ܼg1E>ɥ�X�+=�Q��!��=T̽}Z>�y!����:�E�=m]�=����m�=�K�=�P��Ĉ���L>i��<co>��l��\�>c���;>{R�=���<?߂=�c��=�b<�;��s�Z��=�΅�_�=�̱='�=f�o����MZ������>x>���n��@S=�=eS=z�땪���t=^��N����Ҽ��(�V�o>���<ţ�=8=�YN��0�=���=f�\=���=!�ͯ���Z>X2$>�;�<�պ�m���j=��G>�l>۵�=�h¼�=��B=w7���}>̲�,P[>���a�*=t×=�r=d�4=����ؠ=z3�<��)=)w�=P��
@/�N��i��A���1���>G��=�Z>��=��9=.j>�ā�T�]=�t��8��]>��)>��j��i�-=>-��ww�ڛ�=[-v="%Q<�F=+, ����p�=b�u>�L>�b�������}=�߮>.��==�=�a>{��#���:�R_]<W�=4!t=��j>"�=�/���C�=���=b:;@� =9m����H�=��4>m�>�Q�Qa�=YD�:E_<�e��[��˻�yZ>�y>�@X>�	>.�<G��>����I���LF�=�ɽ;���O��U�
�X�e�O�I>�2>�8>K�->swY�ݿӽҫ0��{���a���]��c�=�v >Y�L=���<k蕽S5><wW=k�U�e��=Fc<���!�n=���<�傽�>ҽ�QF=x#=�!�<ZaJ�]�\���>�Ԫ;k9�=_༸(>a>266=�<�>�Vr>���=?�=n��=�	�=ᅫ>[᩽�>e~��f=���=hݿ��*>��=��p<2�1>���"M����!�׽�̄>G����>�3��N�E�vU�=@68>��>Д���G5>FVl�ڮ>޿�=Oف<i	���a5���y=[Yo>������A���e<��=ly>��8!>�>>��>G�J>�y�=i��=VpŽo��= �=��=p�J���B���f�<BU��&�@=Y���#3�>)m��g�?>���|��=
�`>Dt>��P%�=��>�B>a!�;6�>�Ǎ�p(�=��=%�?>N~�Σ�<K��=�'�q��=B��=Q#�=x� ��<���=��W��*>��<�mQ=BPn�rL����4;׼=��=�-�=�����}�=�	����>C�=��׽�R����u<�Y =̑g>�Ƨ=�>%ξG��>��ڽ �3�%L�>Di=k�c�	T�<�׫��:�<K�1=��1��:�> ?/>ݙ0=�f4=�C�����U�+<M,���Ң��a�>$��=�r��ݭ:>d�2=�H�=\�=�np=Q�;���"�m<@@$=�6O��E�=�6�=e|Ͻ�Ff=�L$����<>����ۯ<��D�_�:�?�=k�=�8�=���,�P>���=9T=h}�1g�F�I�_��Z��#Z4�8��,���
�@�ཨ��鈽=�l��)�;�S�=��q��r�=�ʀ=
�v��SH=Z2���0�=?w?>FA>�P#>n2�>�~E>D��=ݿ>j��=�j�;�8�=���=�{�=�
8>�(=}��=Tૼ���=��{��nv=���<�垽�4=nR�=l缈�@�R��=>��=�=��=P�!��<�XB��>lԁ=�~��,�*>ũc=���=��C=_�>x��>���=oU𽛱�=t ��O<���=��Ž��=�w�!�@���>�.&=L��{���)=�V<��ڼ���=���E���~�U�L�&�8�Z/=G!�>R9a>�ӽ����N'���=>�뎽0���q����N�<5aK�@ݯ�}�j>�ī>�>	�t>@M�-��= iL��ň����=��:��~�=E�w=���=�?">���5 �=�`i>>��I��
��B>��M��[?=+3�=c̫���4>��g=s�=H|��e�$�:�轎J�;�p�>+e���_�<fE >i�� �>�*��o=t;T�s��=e�=Gv��S�>Hqs>p�>���=�#=n7��=:>ŉJ>��A����f6�=OT>����;>'d�=��μ�˷�@ī���=9 ��>-|=8N+����<;>���=������&;��>�wq�#;(��<HҊ=��M=��~=�'��>J���I>�#}����vͻ��=d��U�">�`��f�5=�5ʼ9\>����s���.�N�=� #=�'�=�I�<�aD=�5>����:=U����Q��B>@�(��M%>\+=�z>^j%���>�M���
X>�D;�{(P�=q<�����=�3>b>z.>\��=BzƽV*�=���1I= �>=��=B:B>�z>��5=:c����<��U<ԣ�=�
�����H{��$'>�$=��Q>?�/>�=�rf>�/>���P4=��!����MJJ��ؽ��=�Յ<�F�=��=�ь=;�漷Q.<j�>��}�ޚ�=�S	������I��V˼A�;�>=d<sD�_# >(ǃ<Gꏼ44Z>x`�YD	��Y�=�� =_>��=L�<���<!�=��[=��>c@>����w��=��=��@���=��<To�=+/�=��=hY�=�]=O�<�/�<Կh�s�r�آm���<z߳=�Cc<=��=C��=@�!>���=��k>����sL�=%h�>��a>jp��.��8��=6�>���;�ߗ���=Ue=>�xb��i�=v�#��a���>t㋾KSн��.>��H=��c>L��=1:��!)>9�>%�� �Ǻ<[>�
`<'�#?���>@Gl�D*��VE�V�<��L>L�<�J���)�?S��w'S�#�>4X;ɷp�\ώ���1���$=P��=��ɽ��=��w���Z9�\��=�I���/��1^�=�g�=�G��K>ڐ�=U��>�*��e�=�:��o�=����=�<+=�	��l޻1�=y���X>�Ò=��=�+1>��>¹�>����4u���=�%�m�7��A'�XdA���K�'�(>@(�=�O����+Y=R&H�Q�A�h���0M3��1�C��q�����"��n�>������=ع�<.+�;�@=�U�>P|�>��=A���n 6>�|<�m-��Ш�w��<ox>|»4�Z��>�<���!>6�T++><�����m��ރ<�Q�=0~\��p˽f8�����>�&�=L_��H��-`��mv�="iU=���m#.>�n>T��<8+>g��>�*�=��Z��<�����нΤt�t+���K>���L$��Fe�$�9>�v==1�<���=�[�MD>�C��~E�Up�<���<�ý���=o��>�Ƚ{i?>E��='���yG�=�n�v���G�6=��K><C�u���g�6=9��BӪ=�oc�,��=6^>��$=Ň���<��>j��>Ҙ.>�Y�>$hq���>��=��<�>=��>������<p}�<rL>[�>�1�><aM==A�=R:Z=��=~�C��ʈ����;���<���=ϑ>�=>9s��2�g=%����:����b�<�!<�|�=�#>'A���{��PmܽZ��<`�%�G�m����<���=	�7�|u���=`M���=Y�>���>B�ƽ�B�=�v鼋�+<@���+&��� �#">r�o=g���^>?=������0T�6q@=er=�U�[�1���=M	A>ݽ<=H�G����,����-�P�=�=A=�1�=͕�=w��=
Bu��@��	�� �}>�<�ZĽp��=dB�=�A4>CuK��m ��2=$�N�OF>�y�i�b=��	��B<�3ƽ��ҽ�K>�$�*��=��<�ѓ�:K�=��<	�1>��b��a�=�v0=SH$�:T�<�x
>�9J>i�$=&�<�RL>-	���\E��mP=�2���#�C��=UFY��d^<)m'������>�,��2>(>�白�`�<]-8=����}��� ~=Q��<Ż��'󶼮_��L�;�[=ݰG>$u5�!�F>��>�^�>��=QT���=j��=$�=�>Ө�=�y>px&=�?>jE�=�?�=l���>�Sy<`�>y�J>/k:<�3v���Y>v�.�-��=���<ڂ1>>e'���>>p߾��K彣��=U ���p�:=�c�����= ��<�f���H=��>6� ����=� =}��;b���FkA>�9C�c�q>�~��������g м�>����n˦=e��=�<=S�m�\���_q�����f�&<:Ҟ<%}�Ӧ=�|�=B)�X���U>�z��#�<��c=���=�l�= HO=��G�=�=[�[>�[�W��=�\>�
����k=���Λ;��9>󽣽i8~=�� �/�=?�=��>�阾UK��)z=�[�=S��.�<7r<=�HK>�`�==����<6��> d7�E�=�u��a,սA�@���&����=The>���;O��=Y�`���>DfD���='u�=ͬ)>ߞ!�zZ=���*�1=9�=�P�=����&=�Ю���<�b���G�s,��%>�"&>�Ϝ>�s(>^g�<��c�"*�>Pt*���=:BG=�HѼ�,�=�Y���9���B��/:=��=���`���ؓ<.�0=�1L��h>F��͑��(>2>�>�5�=�tb=�~�=�Tk��n漾�P>}ݚ����<`&��>(�!>�8>�~�<^P9�oy�<BT>{]=e�-;�n(>�24>�(;�W~=��i�>C�<�ť����=��s��'j=<5��Y����=D|z��uT>��ӧ5>B�= �0>?I����h=n�=��8>~���)�6>z���5>���=�z�����=�Q1���=@������=5Y>*�=o�>>���<�й�81�)�4=j�=*�������E,=�ܖs�fؐ=���_�[>X�A=��:>�0!>�չ=�7>��=%Tɽ���=T*�q��/k�=�^z=:��<���=�����=�D>��'��m'�1�G>�n�^_>&��Q��>�&}=d�>#��<mߘ=�9�;���<�����I=�r��RBG�:��=��$>����O,�=zj<�'���h]�յ=�|=gUt>ꦥ=�m�A�<�BU>��=�l�=
�f�)�o>�j��䂰;ծ�=�c�<'''>��/��
����c���8=UK�<���,�,H�=~P9=کR<�+4>t��<�����~(����>$�Q���n>�:y�;�=K��=`��<~ M��p�6&>0Ix��\�=��!=;>�0���I�=O���Cq��*�*��=����>�k>���g9=T%k= Hu>��;>A(j=�[½/�2<B;E�=�M��9>؝*>:Rz=?��=2q�<�<>>P�C=��>y�t�{{z=ͷ�<3>?�J>|�>ɮ^��u=�h;��.=��<�Z>�9=hF >�e���=2>_��˵r=���=�R3<OzS>�o�fӼw�>\)=[Ȩ;2=2d>sڟ=sg�&ڄ� �<��=��<�Q>�t�=���1Kx=tN=�eK=H�4=k<�G��_��hýbl$��E��Y�%���N���b:?`����q� :L������z���z���ͽ���8_gD�~We=b*�:(���~㽋�,�!4�<���K柽���=��ٽ*���F$�?+�񕠽���<[�U=���S=����b�Ƽ�=>`�<8<ݚ��hr����=�ɽ/��=�36��i0�3= ����O�~�H=&[�Ű4�҅E�t�����Q=r,T=�e��iH���
��;=r�	=��μ�C�����ڑ��U:��2<�������� >�� ��5 <#	5;5SN���V���ν�TL�)=��       �� >��%>���=^S�=;�=Ң >�a�=Q;�=��=��ǽ�-'>y����c=�/>�󯽄`>��=�46=�?�=f�!�       �[T<SdýlԺ="� �9��N�9=��>lo��u��<�<M�A� �u�e�<j���;���r���4��[�=	a�=V�       �]             �A�?��?-0�?E�?锚?���?���?y�?y��?�Q�?�k�?�T�?#E�?�˩?�g�?�?�?7�?�ڋ?*j�?%�?      L=�=�/׽}�q�ܽ� =�2>���=��J��2�=��<��S=t�y���w=c��=��:>�� ��I=��=)$�=-�o�����=���=�鄽����I���P�}�{���M>+��=�������;c*��c� ����'���`�d�{���h׆���|<�b�J+y�����6C�= ��<ŃJ���ݽ�ӵ���� �9���,>.>�u@=͐�=��<��PC>Y���Ͻ<'�=��O=���<�2��`=e�>�9�<0�d�l�>��<p�;��	�=M��X��?|/�L:���%w=��.��ŽWeڼ�	��钾=�P=���=�߾ %k���W�Ṻ�����1>��=_��7�U=�(>>�6>'�=�t�=W��[���J=�),<h�T�RnF��|o��Y��{�z��<�H����<%2�=�u=��<�vn�4�1=j$�Ŝ�=j�>H��'� ���LH�������C��=������������!>��S��}�=���=^F@>ִ=q[�7��ꄢ=���������G �s׼o�<��;=��>
�S�j؎�/�����/�%r���{)��EU��[�=�ʼ{�B��T����o�%Xa=Pk��X�|��4�<�+������<��=�|@>�нslX=��<�~K>��M<å�����=C�%<�!=b��=cY�G���/��<ߝ�����@怾�p���G���
>z�y�Al�� m>�&�&�2=Ϫ�<M�m�=����u�f� F�)WK<@;v�W�������M�>��]�ꉎ�陸=-ü>�O1>�V>G���R�2->+��=�0�N~��I���v ���*=E�=��=���e	k=�b<������5g<
��?짽�1)�}�޼�ֈ;��=={��.H<1�=f-��ս.ؽ$��=X'	>��<�4�E�;d��3z<	��;q�+��M=��=O�>�	>�$>�i���z4�կ�~H���'��ۼs��.�ż�e�=3����U<���=h�{>h	>*��%�g�Sй>��<��>�\}>0�=>K��L����B��	���sG��nY�$�*>ͩ�==|=�*�:G�v];>s��=�z�=nb�#���>�璻�\�:���>}��/5�3W��g�;y��<d���q>��6��z�=C���U'��)H�a�0>���<��_��B0�7p�=�
��@�=�#~����,��u�=!8)>����	�=_Wv�Iq>�NR�u+\�@��=.�	�\��V5��� U��s�� 7���<$̼;�[�;&�a=)_=�H@<W߁�
��<�-�<��=>Ͻ�p����i=�����Q1=���=��
����Z?s=Uo�>������<�&<�;=�]2�y2P��J���I���>���<�I�t���ͽ�+��y=>����>�!���p�����^6>��Y=���6=��=kܗ�9���=��=����
=���{=��͓S�*�^=l��=�?��+�=p��G��<u�Խ�����x�ej>:��=�4����k�=�t���=�>D����9\�=��w=����G�=�{ �C$=/v｢ ��=���=Q��P락E3���]�^���>��>��.<	链�r����=�d��=IO�=k�ս+f�=7>:��<�h0����@ e9�̣��k0���2������%N��*>���=�;��ߐ:��u>���>�?�GI,=3��=o����k>�|Q����=V	l��խ�K� ���=;�<K$d�7q�<�'�=;#a=�a�<Y�<�x��&�>���V�a����<&g�	�S��k>�����w����<���=��M�>�=Ndּy�*=�Z����B>�J)��(�=�=���+��}�=�Ľ�����ٽ�{=�zP�膎<Ԫ:�JV=��=�No�Gč=
Y!<���A��=Ix+�}��a�=fmN��P[�0}l���ٽ+�½ZK����1�_�0=���=C��r7�=���<�|&��(��$�=�Q*���s�vLG��W���SC� ��vY2���=����E�*3�`ϗ�Pr.<��;�N�����:�V=��l�����ڜ)���;������=2�=��g�#���>�N����<��q�W�k<��w��#=�G��_���jS=�>���=���=�/��[֨�֜�> 	�=�s2�a�f��$+=�k;�J!��~'�=U��$V��j>���<-;x>C�D>1�����������	>-��=�|�b��L�ܚ��)����=��9��g>J)���:>U���>Ŗ>=�>�jm�l=�p=k��<Da!<`�Ƽ� ����Ž��;�й��D=��Ƚ��&=#�-�<�x�����{�<�t�=�45=#g���<�3���Z����>�����HP���>��z>��>>�˽;�>�,�=�'����=dv>��p��DO<҅V� ����I<`}����=��U��Ʉ=f�Q�u��<#n�>�2S��f=3"�<��>Y�������'�
���_$@���
>4�y\<]\2���Z�Q����������Vf7�5v<�`e�ͬ�1�?���4�<@������=�R�=^]�=~��I�R=�e->�M �_�_��i�����
������0>O�=˯+��a�L�w<�O���ڔ=��C>tw���v��|�>$��=��d��L�M\{<�S޽E�8��L`�̶$�ٹ<�'o����=��� m�(u�t򃻩��Q��=�8���l����%/<�=�<�<Ԯ�����ӽI��D4>�_���xD�����#�=�iߕ=��=���<
��=������.�L�R,��XU=2		��A@>�{�����=�T<���ԃ��j����X��R���w=�]P���e<@����g��<�t�=BH�=�Y�>h"T>!�H����ϳF=�'��
�I�"=�>N���o��:ѽwR;��콯1,>LvO<�����S;��Լ���qu6<�W����*0�8[��	֖=Ҝ��ψ��<��V��/ >1�}=؜=l�=<��ѽg%><�Ѷ�Q��7z��QƼ=w_���X�<pz���n�����;�����ZK�>��E�{����>�i����/�>��>���;{�h>\��<h4�>l��h|���F��u��rb7=�)C�ھo<�h���=4Ձ��B����Խ�Y&<-Ի]��=�ʟ=;�>�.	>�P$=��ڽ�ґ=��0>%%>=?���τ��9�q���&<|��<�!=��e>��������=���-�<퀊�➽��,�˸���i@���2>�#"��'��v{=����T>�Q^�����=f_u�3����F<?W��|4>R��=��J�]��<���<��d�B
>d�սZ����Ŭ�3���(����<,�ͼ��;��>����m��a�����oG����=���qU��S��˞�R�����=�F>���<(���bU�R�m=�ë=�%��,#>�W'=<���F*P�������+>�0>D�K=�>%V_>�q<�'���>��<4.=gؽ����@�>��9�?>@�Q;m���]b��o�����_ql��F�<�)'�n��=�~��8���"�<(����F>0���`w���<P>�3���$Z>��i��I$Ƚ�qf�)�2�T�<=�&=����ɻ��/�U�ǻ�=>��:;47��y���=`eR=�=
9=gO�=��>�b.�kO�Tӯ�

����Լ��d�c
=��7�ؤ=Whw=���<�5�<�=a�L=t���=�?��qȼ^>�==0�>T᧾K&�R��H%7����T8[=wO���sL�Ͻ^>A��<;�u��V��DR><q=6CA���=�W����� �=����lO>�dh���<J=P���~*�K�|=��R=6�+�A�U���=�?=�
z���=)\P=Za��ؽ���n�>���=�`������>=sޕ�����<=�@߽�ɵ<�:�=����ow=���u���f'�)~R�V>νp�E�u+�YP��%�R��饽XH;�k<�{�=���=���=�]q=9b�=wz�<��%���žݐ�	5�=�n���2�=x�=��x�Q����	�7W輤d	=�P�����=]�=��02�:T��-��=�F���4����#6=ZPI�Di[��7�=d����/��r�=!X��^���5��=QĽ�K���V= vo=�߼<�9ѽ���Y��=��8�Rxs=����<�27�q���Z=���b���\�>�w�Kzw<4\Z=uu�<iJu���<Z��=�a��b�wF��q���^>�S��Ȑ=u|��*����|���	Q����;�L�Q��MK���={������<���=�nk����=2~½�����,�=h��=�!V�]@3�N�?$�<FU=��޽}��;m"�=.�Q=Kǽ�Ⱦu��S���>�=M����_��䙣<�b=Y��&)�<����&��B[=�!-<I���/R�g��=��=�R�����\��<�q>�(>p��SR>�e}�`�ٽ��w<qC��R��+-��1m��!\���T:���=	��AI�=��V���2|��3ٽ~o(>
O6>�L�=��=��>�xT�:�G<�f�_�=fQ�0��<��Q<�\�=��b�p=1��=�"�=��<u;<��#��(,����>-�*���<�D!;�ˣ���T�A��=�l=\�G�	=Z9�=�o�=�^���H��C���sļ�s�B�i=�g_=�4>��=�/�=�&�<�o�<MB�<��߄���*�;�Z�g��=�&�\���Q�=ľ���CD>ܩ> D��Z�O=Pvs=�,K��Z��v9g���=g�н�L=o���1�=�q�G�d�~� ��z�=5$>U��@�~=��������-=�9=���<L؃���=��=��/>Tk[�=�=��=�Mټ98��u�i����=����BL2>wr=́=�a����=��=� �=@�F���I�&z��s<.��Q��������[�>4��; �C>��;�\�=B�λ�[�:
u�I��=A�=2D�\�=!�.>,��=�Fy����=~m�~Ԍ==U�<�͈���&�b�
;���=<��>����[��������}>�r�=��g=HT)�Дټ�)=L�j���uv��ݿ=w��d���t�q�qځ=)	���� m:�G��]6%���Y3�tU�=
)^�w�}���;��=xd>8󊾦��=s�&=�!��G�?=T����>&���VR;1ϓ�񣼽�욾�`���k��܆���r澽Xh7�j����麖�;�Z��J�����=�=N�=D��=hw��ս��=h��<{�e��ⲽ[2T�S��a8�)���t�=*G�"y>2�P=d�=O9J>[��ٹ��8����<M��=�T$=��>g�چ6�[��M���C������=��h���b�=�r���뾿9��_
�r��=r牽�b?��e>>ￂ��"=�
>S���YtE����[��:Ǝ����û乼��{>��e��Jg��[+�+*=�!�<Ynq=Mj�����i���?��#[g=a�ڽ�[����=sp��J.��ٽ�
�@H��l ɽ�N���e�<lĔ=�'��9�=XNs�:@����+���f=�@Žx�>��Wk<����w<��ѽǛ�<b>�$=g�=���=fM
��'��נ=x9C��O�=�����=>8(��R&>$([���>��.�K�>sU��2��~J>F���1��=4	A��J�;�0h�+�>ю2��%*�ğb�LQ�)�Q=�U�{��Op��=��=m|3>�}<���=�����d�=�� 3<���ڮ��n��>>Ɓ���;���2�3窽&��=��&��䄽=(�=�\�tI�� >���=�>�� u <壟���=9{=�=%>J�,�K�)�@%�;@Z�SĽ���(Y�=QJ��ә��S�=Z��gń�9hb�
=dm����Q��<Y精��6<��
>m���@�=�ۻ�:K����=}�<����R�E�����i�6a>�Y>��8>F4��A�ٞ��V톾��n�Y
�<fv�>�����=�5�<��ҽ4�7?�=���3lO��b���:���׽����)��=e�ؼ�M��L����d=�"�=8�<�BV�=z�>K<�n潩˹��˹��H@��f�;���g�ͯ=��=�8ѽ�~D��DP>��w<�@���z����<��{�&~����>jv@=s�b=���=���,��q>����J��>;=,G�=�Q��>���=QPW=�I�;ɞ���&�}f�=� >����8�=3�X>�z�<�<�=W���5�==�߽A���=O�ٽ�����f��<ľ�E���Ľ��=�hJ�͕5�YW�=i&,��{�=�V�=D׻�%�L�H0ڽ�E�=f�->wC�<Tkx<\)�=���;(��,�*=��^=[_<εu�Rzp�Z̹=�v0����=l���$	�Gp>r8�=}��$���fu<�B��=�B>�����$>@3t��	� �#�͕[��<8�<=0>=�2����V�I�<��7�5�j=�B����@>ڣ�"M�<��E<@�_=F���=
��B���8���E�f�M���?��`>����$��PF=_��<H}y>�=.b*;z��<�	���C>��������Bɥ��@�<R���z�]ѽ�G��♽lӛ=���=؎��V�{�=0@�� ��h��N)�c�>{�D�0`�S:	�/-Ѽ��<6a<D��=�̧�j�w��u�t;B��\Q=����:�A=#O�=�� ����H�c���<>�C��{�����=�D"��H�=��=��ļ�q�=�F����x)m<���=FCx��狼���<2[ >�-�=hӚ����ϼ�<d�=���=�<l>񈎾f�F�������޻��z��F>2
���w��=�%>(�`=��>D���?L+��F��7P>��o=pk��!=�Go�Ui����/>����|<�Ǟ=�I
>��z�k�N>�����=�|{�������=� *����'�x���$�}u7��|#�́���e�>2̕�@r���C>0݀���=g�����Ō>��m��=Ʈ��$(��c���_im>/n�=c#�(� ��
:�A#>Lq$��5l=,���c���!�I�{ �=�" �dkC<�DK���x=P�<%v�=9�<�
↻��U����=�$:�A��AU=�>>Aݲ>��H�6�x�j<`Q>�J�"�����=U�.>��H=��߼�1���Ľ(��kOR���k��s�=jaɽw�����H�9�=o�N=rFY������y=��=o�h�0�2>�~�9dt�>U��<�ә�i����a��*I,;j�<<��{Z���W1����O��$���ɖ�OV2;��=teƽ�i��]��<d�4�_�=��i=���5�%�G�ռ��<���=>��i����(>bp��o}�=�^���>ӑg��֓��K
� ��� 6�d��{��/=�p�=� �=�>���	�Tmûߩ�=�/�Ed@����:A>�y��8I2��~��o>��u=����k������~(>�^
=��-��\G=x7�=���6�<w�t��+��.�=�㞾�����n��=��M��_Q��)����<�~����5���a���@�;+>���<=ȹ=�|7=��=���<'
z>�Ľb����o�=�L>=c����{ɼ��ؽ�Ŝ�=B�<��$���= �#�� ���9��Y�=�����;�����=p��a��>K��j���SZD��󑽬���,�=� 7��"��&z;���<v� ���
��q۽�#�̣�=�@�=�O\<!������,��d	��@l;���<�R,��@��t��p&�=@�k�Q!�����ۼ5�>�N��6_=��c=�-�< ��:+����>��=}�;��L�=�G�=�饽�ؙ�[M�{���M��.2��R��E��<JR=iY!=��T�zi�=�B˽��	���C�~WX='��=ʂ��V+=���=�[ټZ|%>�K���~>�Wx���i���.=R��]s=��;�Ts�B�M>CX�=��c>�� =�u�<��>	@=ϰ=k<��<�_�\�=	νy>�9�0�����g95��}���2Y>��X=�������܄����Z��7q�p�=3<��c�<��a��=���F&�5�+�X3ʽ{Ug���&�zC�=�ʽ�i1�~s>� �=VG��/�m�6͛��8<ѡ�>�`�<�����=�@��R�=й��A��=먞�j�꽄м�=#�齱��=��B<J���h.�ZG=��;~NM=����l�=� �N�м�����V�8U>�/0>2X����?3���=�P>������]�<�T	�[�b��3��=&�����<
>�_�<ؕ>��>��H���>��>�C�<g(J>-�I�d<����$���@����jq�S�����aF���總:�!�#�d=�'���t��2�*�>�>�<�:�[D�B��=��!>�g[��=)��=��������V���=ȅ�=��<�ɼdV�=r�r�U��=�9�=I���(ڽ�j��놏=�rs=I8�>�Ƣ<�v8�H
><��N��5�=d�Z=�ds��r};j�=�E>�w��\z�'�C>'��<{� �~mv=+�������2=��˽3;q�����.�qa9=9���Z��R���=k��.�ؽ���:P�==4D��G=����ٛ����>���=���=�j��c�=�">�e1=$s�=��>��>�͊>�G������=�p����n1>���>5��=�M�=N*�'bJ=�P�<��V��!;���=[}���Ľ���̸>=4=}�x$��و>g��> �/�����黗�g�i=�w����<�F��:R5�9��=�޻5��<���5�ٻ�����=�/6=��3>#�����(�]���ʹ8����=Ȏ�n%<|�C�;]��c�
�]��=z��=S�0Bj=H��@\���ʽ��=Y�� �<UF)=�<���uq>5C >��)=��h= &=�ͺ=�c�t�Z����(�]�*�N2��i��w������)`��>�lb�C�?�߄'����=��)�q�>���6�-sq�oZ�:���0T�<�!m���A=?i2<��#��fx�U^�=�>�ʄ=	U���Z<��ƭ=&'ؽ�9>M�=۾
b��w"���ͫ�)��X<5e'�m��<ڮ<$Y8���Z��&>[м�ݙ<IJ>�[X��m�=�O�Q��=%6��N�>*�	��jr�g.:�c_=�[7>j����k��R"�:�V=R�ɽ��p=�@�=J�S���X���1�E7O����<�	���`�=�5=.p>cV��E�7��y<��Un��=��3�=�tx;�%�8&7>����`%i=�ӽ|�p.���r�����&�6��=3���8�U�#>�9�a::������[ټ��@=�M"=·A=Q߻�v��Q<
>�]ǽ��]>=ߞ�hF⼫���ĺ�=�7�4X5�D�.��O;�j�����.>�{��.7���`�=�'��H���3-�Q!N�vN�=�"i�3��H�d>�����>HE����ý�.���.��o�D�,�=؂�:\�6=q�>�� =:K�M;�}w0�����i����=
���^}�>�%:�s�����h�>Ҟ���<l��q���n�� �>Z��:�V�=V!������$���/>�X��DV����L���'Ku��Zt>r�8=�+>�8�շ�;^�<�w�<'�=��1�Z�=�$>�X��)��r��;�&��G���S����:D>�抽
��=��&>-���q=Z��<i==�<(��9A���o>��<o����C�V���܊��q��A��<g�&>��>��4>�C<�+Ν>.�����,�8��=�Ȯ=$��=@�c�
0>#��T�\=sː��'>~�:��;l����=��N=��7����<��V�@�g�2>��D�|�>�ɿ;��#�!�	�Z���<�R����>�<��jM�1��#�=Q��U���w��s��h���)�\�j�s�����=�*=ϋ
���M�n���s�p;��<0��<`_ս��m=�%�_Һ�-n/���=/Ł���<҇�>�i�=	=�˽,�>�Ǵ���P�w�M�`n}=������s-��kX>U:���>�K@��}½[D=��>�E�44�<m:�8��j!���5=aA��C�，�Y=��;5��<j�M=_3��T�E����~����1�ː'��Gû�7P=�«�"�:�7�M��<�F�=#�D�P#X=�)�9���a�����=Gs9\��
���(�U��A^��1>�c:=	��=Pc=��z��h�>a�=}���9=����˽֢��t>���=���<&��=�T$�ۑ�+��ӗռ�{p=^�����b<�T>㚵=�����ʽ2>b����/�������<���k�_����\�Aق���>YE>�"����<�q=�C2�i�<2>V��=�O|���_�V]x;!o3=�������=���0�;���<��>>W]*=�]Y��iK>U{󽝂;�p��裍>_��;�OU��=����b�=b�U�n�O>��U�sb=g�k>�	;�;��=��ʽY�*��K=[��=�WS;4iW�K�¼��	�W�#G�361�,�	�߆�>�^�=��0>�?����c��⟾��C=݄`=kR���>�]F��6l�& 3>/_���n���=mM��=h򄻸C;����x�<��}B��2�=�冼f]��)�=�G=ϝ��1B��8M�
z�>�%�=�gh�UpG�L{�Z��=t��>��ľ�ǜ��q�<�e >|��=��n=�=$J���s���`�����o�����8��y;�θ|����=h�N�Lr���T�=����-�<|Y����(�ُɼ2�Že�Ľ�c����ʽY�Ƚ<�|<y]����P⼦y�=��ǽ�=x��B��"�`=������<�����>
K;�eU3��r*;e��=!"��ļ���DQ�=��潩P��<�F�����<��4=-�g=��b�=/w�=��=�"A���"���N�1`=�i��}�D<ǃ�=d�C�[�=ݫ�=f?=U"%�~�I=r�=j8Y>���Q	�=�����K=�H�=�ǜ=J�<<ڬ��@E�T}>9	T��V��4�=��)��f��Y�k�t)�<��ֽu楻M�,=���[�-=���<im�=�%R���g4�=�T�=
�6��ݲ��ǽY�a���ửX�<[c>�朾3=�,�<F�U�՜]=�'�� ��θ<��ֽs�X��el<��c��v��29>z��=�i>O�= g
���	�z���<.^>˾>�O��P�y;*�+����=��bn�Y�,����:)3
>i*>F�>B`�>Z�=��j��~K� �;�z�=���=x�0=��h�"��;�pM=�Ua�n�=&��<C5� ,>�?�>�x� ��AU�d�M����`� =^�E��G�=[� �棤;�m�=^��@��.>�%,<� ����nP4����+w�������d�=��=�c��ֱ���AO�PA<����5�=�B>c�B��eK��N��Y�X>M)�����쀌�n~����	>妽CՆ=��!<��ҽ����]Q=���=�p�=nE�=�z�2և�Q�e>�)�>Q�����=CJ��d�<�A��\�p�=�|��4�=���=>R�W�ǽ8<y7�cʢ�$�~=��>ַ{��)=��嬼oн��'�0�z��۽gS-�����>h�b�B�-=N{=�d��蹽%�ҽ}�5�����nt��O�=r�ҽ�;��t�=z/.>ґ<=�v�����->>�=����٢�<.:S>�"n>��{=�Xk=6�=��=U� =�j��J�a>^�>�@���)d�Ǔ�����=A�6�㽂��X�����)=q>���=o�=>���=�z]<WB>0mν�����ȽI���� �T�|��C��!�����=��a<�G.�4r��?C
=(j�~	��P�.;�����o����i=�-�=���=��X	ʾ�`ƹΉý�~ڽI�`��X�_��<�=L4U>\�Y����o��;, ^<�c
>6�!=S����%�=T�>V�;�Z&�6�>�71���">���=�����𣼨9��w�3�2"/�Ñ༞[=�|�D��۵<5&>Qk�=��u�sj>b�/=�c�=�FJ>��b��}�|Gd�=���PN<���p )����=�z�$�Q=��;>�x=�>ѮJ���R�Kh����<�ш=��w���V����~p���4.=�D�=�D����M<�sr>X��v�o���=�G�=�_�o$6>�I�>e�v>5w�=u�;!���C<! 5>��h�I>�l�=1�X>��;�2�.d��i>�����,"<�쌾�6�=Jۙ<u<@
=�N�=^/�����;^���39>���.�>�S�=FVؼ�����r=�M3>/u;�d���2=��h�+�'����>:9�<��=��=,E�=��>�و>�����_��p=������=j��=뽬=ޏ���N�IgX=m�U�2��<!��</��	V��?�d
�yӹ���c=�Y>O �<׾�W��<6�,>��м#�R�~�۽����t��}L����=�9�<�սg�$�p����C>�r�;���0x�=ʉ��b>�63<�0	��i>���<Ї�����8=�qe>�#6���D� -=g�S>p̽�	�=�m��T>+ԇ�
=��:d�=6}��B���\�;�-�=aļ����(㎻�9���=�;������R�=�9<��U�>����s>P#��[A����=Kb�<��%�nٽ�ﰽ�8��
1,>� ��|s
�}&"�G����C�Ng>Mz'>�K>��Z�=:���w?=�k���=�Q���J	=�ue>m�;�lp��y���zƽ��)���%>�hv=My�O5�=��u��E=x��=�c�=����e�;?Zl�.�Ӽ� �=0ϙ��q!�+��=�]���p�;l>*�<��X���GT��D��gY=
�<����9�>Y�v��0H>̩<��̽e�c��Ȑ�����!�e>����)�=���=#��=%?�������<��C�Q��=<X�9�������|��<S|��p�=��ۼ��=���>�� ���z>o�<A>E ��������rW>�����=�r��m�0(�!�?�X��=����c���؝<K��=�1�=\d`�l�s�?╼I	�W���q�_��/ �L]�C{ɽ��=�F��O=}h뽊��=�I��Y�<��5�wt�>G:L>�sֽ@��<�O���D�d���Y7@�}��t��=��2�f�=F6 >�7D>�B�_��=��=��=SI�:�&��p��+g�LI�=��=��d�I½���Է�=���X���������B�~>�G2=@dֽ��Z��<�<;=Slo�*��Dnݽ������R���X>�l�o�=��>�3���֟=�1�5�6��.ܼ�94>k �#�>�="���-�=a�-���_��н���
��=y��=�E<�}�=��?<�-޽#4���3ƽ�鐽W�%��Q��)+�=�E&<ª�=��Q<~;�=y��=���=�v��nQ�.='����g�=3�&���Ǽ"/
��ø�7��`H�
�3>TG�=���,)>�O]����=��o=:�<U>]a����%��p�<K���<�w#>�=�r�=Qhw=�][<u!�/�0=��}<r�Ž
�=��=�C���>��Ƚ����eK<"���鼝�^�P��j��X��J����=���s�Z<@�'��C��^�1��v2\>CK2��n���[�U�I3|�4
�=ZI3�$-=>�o0� ����z>�弔u{��|���G�<y��:����'Ͻ��<��=
=��0=�,!��]���>_���<��=���cP�=+Ȝ�ɮ��Y׾�X����=� ��F�C=��>��I�       ^<?t@�tY?�P?'+p?��\?e�7?�~�?��Z?��8?�e�?�r?c��?~4�?�0?��X?1d??��?g�?